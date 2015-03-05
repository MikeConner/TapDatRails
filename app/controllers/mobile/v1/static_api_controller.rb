class Mobile::V1::StaticApiController < ApiController
  def ping
    expose "Pong"
  end
end
