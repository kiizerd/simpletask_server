# frozen_string_literal: true

# Provides methods for creatind and interacting with auth tokens.
module Authentication
  extend ActiveSupport::Concern
  include ActionController::Cookies

  included { before_action :authenticate_user! }

  SECRET = Rails.application.secrets.secret_key_base.to_s
  JWT_ALGORITHM = 'HS256'

  private

  def current_user
    @current_user
  end

  def authenticate_user!
    user_id = decoded_token['id'].to_i
    begin
      @current_user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      @current_user = nil
    end
    # Return if user is valid
    return unless @current_user.nil?

    render json: { error: 'Invalid user id' }, status: :unauthorized
  end

  def generate_session_cookie(user)
    token = generate_jwt(user)
    cookies.encrypted[:token] = {
      value: token,
      expires: 1.week,
      httponly: true,
      secure: true,
      same_site: :none
    }
  end

  def generate_jwt(user)
    payload = { id: user.id }
    JWT.encode(payload, SECRET, JWT_ALGORITHM)
  end

  def decode_jwt(token)
    JWT.decode(token, SECRET, true, { algorithm: 'HS256' })
  end

  def decoded_token
    @decoded_token ||= begin
      token = cookies.encrypted[:token]
      return {} unless token

      JWT.decode(token, SECRET, true, algorithm: JWT_ALGORITHM).first
    end
  end
end
