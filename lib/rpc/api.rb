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
    model_name = params[:model_name].constantize
    result = model_name
    params[:method_chain].each do |element|
      result = result.send(element[:method], *element[:arguments])
    end
    result = JSON.parse result.to_json rescue result
    render json: result
  end

  private

  def check_ip
  end
end
