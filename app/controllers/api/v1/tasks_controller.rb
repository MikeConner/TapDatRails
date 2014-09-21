class Api::V1::TasksController < ApplicationController
  require 'nickname_generator'
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  # Just skip the authentication for now
  # before_filter :authenticate_user!

  respond_to :json

  def index
render :status => 200,
     :json => { :success => true,
                :info => "Registered",
                :data => { :user => NicknameGenerator.generate_nickname}
}



  end
end
