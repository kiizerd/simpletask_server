# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  skip_before_action :authenticate_user!, only: [:create]
  respond_to :json

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource, store: false)
  end

  # POST /resource
  def create
    user = User.create(sign_up_params)
    if user.valid?
      sign_up :user, user
      respond_with(user)
    else
      render json: user.errors.messages, status: :unprocessable_entity
    end
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end
  private

  def respond_with(user, _opts = {})
    render json: { token: user.generate_jwt }
  end

  def respond_to_on_destroy
    head :ok
  end

  def sign_up_params
    params.require(:user).permit(:email, :password)
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
