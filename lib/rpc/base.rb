require 'httparty'

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

      def request(eval_str)
        puts eval_str
        url = Object.const_get(name.split('::').first)::BASE_URL + '/rpc/ar'
        HTTParty.post(url, body: { eval_str: eval_str }).parsed_response
      end
    end
  end

  class Relation
    def initialize(model_name)
      @model_name = model_name
      @invoke_str = model_name.split('::').last
    end

    def method_missing(method, *arguments, &block)
      case state(method)
      when 'complete'
        @invoke_str += joining(method, *arguments)
        run
      when 'uncomplete'
        @invoke_str += joining(method, *arguments)
        self
      else
        run.send(method, *arguments, &block)
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
      if [
        :find, :take, :take!, :first, :first!, :last, :last!, :exists?, :any?, :many?,
        :count, :average, :minimum, :maximum, :sum, :calculate,
        :all
      ].include? method
        'complete'
      elsif [
        :select, :group, :order, :except, :reorder, :limit, :offset, :joins,
        :where, :rewhere, :preload, :eager_load, :includes, :from, :lock, :readonly,
        :having, :create_with, :uniq, :distinct, :references, :none, :unscope
      ].include? method
        'uncomplete'
      else
        'reinvoke'
      end
    end

    def run
      model = Object.const_get(@model_name)
      result = model.request(@invoke_str)
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
