class ApplicationController < ActionController::API
  def sleepy
    sleep(params[:ms].to_i / 1000)
    render body: 'ok'
  end
end
