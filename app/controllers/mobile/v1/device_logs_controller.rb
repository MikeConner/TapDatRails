class Mobile::V1::DeviceLogsController < ApiController
  before_filter :authenticate_user_from_token!
  
  def create
    DeviceLog.create!(device_log_params(params))
    
    head :ok
    
  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}    
  end
  
private
  def device_log_params(params)
    params.permit(:user, :os, :hardware, :message, :details)
  end
end
