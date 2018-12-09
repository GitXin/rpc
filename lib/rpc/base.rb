require 'httparty'
require 'rpc/permit_methods'

module Rpc
  class Base
    def assign_attributes(attributes = {})
      @attributes = attributes
      self
    end

    def method_missing(method, *arguments, &block)
      @attributes[method] || @attributes[method.to_s]
    end

    class << self
      def method_missing(method, *arguments, &block)
        Relation.new(name).send(method, *arguments, &block)
      end

      def request(payloads)
        url = Object.const_get(namespace_name)::BASE_URL + '/rpc/ar'
        result = HTTParty.post(
          url,
          body: payloads.to_json,
          headers: { 'Content-Type' => 'application/json' }
        ).parsed_response
        raise "Rpc: #{result['msg']}" if result['code'] == 1
        result['data']
      end
    end
  end

  class Relation
    def initialize(model_name)
      @model_name = model_name
      @payloads = {
        model_name: model_name.split('::').last,
        method_chain: []
      }
    end

    def method_missing(method, *arguments, &block)
      @payloads[:method_chain] << { method: method, arguments: arguments }

      case state(method)
      when 'complete'
        run
      when 'uncomplete'
        self
      else
        if block_given?
          @payloads[:method_chain].pop
          run.send(method, *arguments, &block)
        else
          run
        end
      end
    end

    def joining(method, *arguments)
      if arguments.size.zero?
        ".#{method}"
      else
        ".#{method}(#{arguments.join(', ')})"
      end
    end

    def state(method)
      if PermitMethods::COMPLETE.include? method
        'complete'
      elsif PermitMethods::UNCOMPLETE.include? method
        'uncomplete'
      else
        'reinvoke'
      end
    end

    def run
      model = Object.const_get(@model_name)
      result = model.request(@payloads)
      if result.is_a? Array
        if result[0].is_a? Hash
          result.map { |attributes| model.new.assign_attributes(attributes) }
        else
          result
        end
      elsif result.is_a? Hash
        model.new.assign_attributes(result)
      else
        result
      end
    end

    def inspect
      run.inspect
    end
  end
end
