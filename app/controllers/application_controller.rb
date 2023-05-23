class ApplicationController < ActionController::API
  include ActionController::Cookies
  before_action :authenticate_user!

  SECRET = Rails.application.secrets.secret_key_base

  private

  def authenticate_user!
    token = cookies[:token]
    decoded_token = decode_jwt(token) if token
    @current_user = User.find(decoded_token[0]['id']) if decoded_token

    return unless @current_user.nil?

    render json: { error: 'Unauthorized access', debug: { token:, decoded_token: } }, status: :unauthorized
  end

  def generate_session_cookie(user)
    token = generate_jwt(user)
    cookies[:token] = {
      value: token,
      expires: 1.week
    }
  end

  def generate_jwt(user)
    payload = { id: user.id, expires: 1.week }
    JWT.encode(payload, Rails.application.secrets.secret_key_base, 'HS256')
  end

  def decode_jwt(token)
    JWT.decode(token, SECRET, true, { algorithm: 'HS256' })
  end
end
