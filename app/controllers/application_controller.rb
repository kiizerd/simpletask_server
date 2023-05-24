class ApplicationController < ActionController::API
  include ActionController::Cookies
  before_action :authenticate_user!

  SECRET = Rails.application.secrets.secret_key_base
  JWT_ALGORITHM = 'HS256'.freeze

  private

  def authenticate_user!
    user_id = decoded_token['id'].to_i
    return if User.exists?(user_id)

    render json: { error: 'Invalid user id' }, status: :unauthorized
  end

  def generate_session_cookie(user)
    token = generate_jwt(user)
    cookies[:token] = {
      value: token,
      expires: 10.seconds
    }
  end

  def generate_jwt(user)
    payload = { id: user.id, expires: 1.week }
    JWT.encode(payload, Rails.application.secrets.secret_key_base, JWT_ALGORITHM)
  end

  def decode_jwt(token)
    JWT.decode(token, SECRET, true, { algorithm: 'HS256' })
  end

  def decoded_token
    @decoded_token ||= begin
      token = cookies[:token]
      return {} unless token

      JWT.decode(token, SECRET, true, algorithm: JWT_ALGORITHM).first
    end
  end
end
