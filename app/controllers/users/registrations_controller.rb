# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user!, only: :create
  skip_before_action :authenticate_scope!
  respond_to :json

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource, store: false)
  end

  # POST /resource
  def create
    user = User.create(sign_up_params)
    if user.valid?
      sign_up :user, user
      generate_session_cookie(user)
      render json: { user: }, status: :created
    else
      render json: formatted_errors(user), status: :unprocessable_entity
    end
  end

  def destroy
    @current_user.destroy
    cookies.delete(:token)
    respond_to_on_destroy
  end

  private

  def respond_with(user, _opts = {})
    render json: { token: user.generate_jwt }
  end

  def respond_to_on_destroy
    render status: :no_content
  end

  def sign_up_params
    params.require(:user).permit(:email, :password)
  end
end
