module ApiHelpers
  def json_body
    json = JSON.parse(response.body)
    json.is_a?(Hash) ? json.deep_symbolize_keys : json
  end

  def get_cookie_jar(request, cookies)
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end

  def authorize_test_session
    post '/users', params: { user: attributes_for(:user) }
    jar = get_cookie_jar(request, cookies)
    raise 'Authorization failed' unless jar.encrypted[:token]
  end

  def sign_in_user(email)
    route = '/users/sign_in'
    params = { user: { email:, password: 'password' } }
    post route, params:
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
