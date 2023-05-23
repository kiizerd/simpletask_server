# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  skip_before_action :authenticate_user!, only: [:create]

  # POST /resource/sign_in
  def create
    user = User.find_for_database_authentication(email: session_params[:email])
    if user&.valid_password?(session_params[:password])
      # Add store: false parameter according with this github comment
      # https://github.com/heartcombo/devise/issues/5443#issuecomment-1337439470
      sign_in :user, user, store: false
      generate_session_cookie(user)
      render json: { user: }, status: :created
    else
      errors = user.nil? ? 'Email not registered' : user.errors.messages
      render json: { errors: }, status: :unauthorized
    end
  end

  # DELETE /resource/sign_out
  def destroy
    current_user&.update(token: nil)
    signed_out = Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    render json: { success: signed_out }
  end

  def auth_options
    super.merge({ store: false })
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private

  def respond_with(user, _opts = {})
    render json: { user: }, status: :created
  end

  def respond_to_on_destroy
    head :ok
  end

  def session_params
    params.require(:user).permit(:email, :password)
  end
end
