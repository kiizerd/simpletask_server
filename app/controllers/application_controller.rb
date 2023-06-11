class ApplicationController < ActionController::API
  include ActionController::Cookies
  before_action :authenticate_user!

  SECRET = Rails.application.secrets.secret_key_base.to_s
  JWT_ALGORITHM = 'HS256'.freeze

  private

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
      expires: 1.week
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

  def formatted_errors(resource)
    return errors_for_nil_resource if resource.nil?

    errors = resource.errors
    details = errors.details
    messages = details.keys.index_with { |m| errors.full_messages_for(m) }

    { code: determine_error_code(resource), messages:, details: }
  end

  def determine_error_code(resource)
    errors = resource.errors
    if resource.class.attribute_names.any? { |n| errors.include?(n) }
      'invalid_parameters'
    else
      'unknown_error'
    end
  end

  def errors_for_nil_resource
    if @current_user
      { code: 'record_not_found' }
    else
      { code: 'authentication failed' }
    end
  end
end
