# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, only: :create

  def show
    render json: { user: @current_user }, status: :ok
  end

  # POST /resource/sign_in
  def create
    user = User.find_for_database_authentication(email: session_params[:email])
    if user&.valid_password?(session_params[:password])
      generate_session_cookie(user)
      respond_to_create(user)
    else
      render status: user ? :unauthorized : :not_found
    end
  end

  # DELETE /resource/sign_out
  def destroy
    @current_user = nil
    cookies.delete(:token)
    respond_to_destroy
  end

  # Need to overload this method to prevent it erroring every time
  def verify_signed_out_user
    @current_user.nil?
  end

  private

  def respond_to_create(user)
    render json: { user: }, status: :created
  end

  def respond_to_destroy
    render status: :no_content
  end

  def session_params
    params.require(:user).permit(:email, :password)
  end
end
