class ApplicationController < ActionController::Base
  protect_from_forgery :with => :null_session, :if => Proc.new { |c| 'application/json' == c.request.format }

protected
  def ensure_admin_user
    unless !current_user.nil? and current_user.admin?
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end
