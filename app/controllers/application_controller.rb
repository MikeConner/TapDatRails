class ApplicationController < ActionController::Base
  protect_from_forgery :with => :null_session, :if => Proc.new { |c| 'application/json' == c.request.format }
end
