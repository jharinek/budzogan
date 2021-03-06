module Concerns::Security
  extend ActiveSupport::Concern

  included do
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    before_action :filter_params

    before_action :permit_params, if: :devise_controller?

    # Add when CanCan in usage
    #rescue_from CanCan::AccessDenied do |exception|
    #  flash[:alert] = t('cancan.access_denied')
    #
    #  redirect_to root_path
    #end
  end

  def filter_params
    params.delete :_
  end

  def permit_params
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit :login, :first, :last, :email, :password, :password_confirmation, :organization, :grade, :sex, :evaluation }
    # devise_parameter_sanitizer.for(:account_update) { |u| u.permit :email, :password, :password_confirmation, :current_password }
  end
end
