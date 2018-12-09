Rails.application.routes.append do
  resources :rpc, only: [] do
    collection do
      post :ar
    end
  end
end

module Kernel
  def rpc_respond_to? method
    custom_permit_methods = const_defined?('RPC_METHODS') ? const_get('RPC_METHODS') : []
    (Rpc::PermitMethods::COMPLETE + Rpc::PermitMethods::UNCOMPLETE + custom_permit_methods).include? method.to_sym
  end
end

class RpcController < ApplicationController
  skip_before_filter :verify_authenticity_token
  wrap_parameters false
  before_action :check_ip

  def ar
    payloads = ActiveSupport::HashWithIndifferentAccess.new(params)
    model = payloads[:model_name].constantize
    result = model
    payloads[:method_chain].each do |element|
      raise "unpermitted method #{element[:method]} for #{model}" unless model.rpc_respond_to? element[:method]
      result = result.send(element[:method], *element[:arguments])
    end
    result = JSON.parse result.to_json rescue result
    render json: { code: 0, data: result }
  rescue => e
    render json: { code: 1, msg: e.to_s }
  end

  private

  def check_ip
    unless request.remote_ip.in? (Rpc::IPS + Rpc::LOCAL_IPS)
      render json: { code: 1, msg: "unauthorized ip: #{request.remote_ip}" }
    end
  end
end
