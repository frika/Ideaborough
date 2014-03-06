class ApplicationController < ActionController::Base
  layout Proc.new { |controller|
    if controller.devise_controller? && controller_name != 'invitations'
      'external'
    else
      'internal'
    end
  }

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_account
    @current_account ||= current_user.account if current_user
  end
end
