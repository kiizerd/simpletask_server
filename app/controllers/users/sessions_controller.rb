# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  skip_before_action :authenticate_user!, only: %i[create destroy]

  # POST /resource/sign_in
  def create
    user = User.find_for_database_authentication(email: session_params[:email])
    if user&.valid_password?(session_params[:password])
      generate_session_cookie(user)
      respond_to_create(user)
    else
      errors = user.nil? ? 'Email not registered' : user.errors.messages
      render json: { errors: }, status: :unauthorized
    end
  end

  # DELETE /resource/sign_out
  def destroy
    @current_user = nil
    cookies.delete(:token)
    respond_to_on_destroy
  end

  # Need to overload this method to prevent it erroring every time
  def verify_signed_out_user
    @current_user.nil?
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private

  def respond_to_create(user)
    render json: { user: }, status: :created
  end

  def respond_to_on_destroy
    render json: { success: 'User signed out.' }, status: :ok
  end

  def session_params
    params.require(:user).permit(:email, :password)
  end
end
