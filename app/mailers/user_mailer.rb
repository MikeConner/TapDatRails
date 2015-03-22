class UserMailer < ActionMailer::Base
  default from: ApplicationHelper::MAILER_FROM_ADDRESS
  
  WELCOME_MESSAGE = 'Welcome to TapDatApp!'
  
  def welcome_email(user, pwd)
    @pwd = pwd
    
    mail(:to => user.email, :subject => WELCOME_MESSAGE) 
  end
end
