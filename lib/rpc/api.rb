Rails.application.routes.append do
  resources :rpc, only: [] do
    collection do
      post :ar
    end
  end
end

class RpcController < ApplicationController
  skip_before_filter :verify_authenticity_token
  wrap_parameters false
  before_action :check_ip

  def ar
    payloads = ActiveSupport::HashWithIndifferentAccess.new(params)
    model_name = payloads[:model_name].constantize
    result = model_name
    payloads[:method_chain].each do |element|
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
