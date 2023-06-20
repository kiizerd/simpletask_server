module ApiHelpers
  def json_body
    JSON.parse(response.body).deep_symbolize_keys
  end

  def get_cookie_jar(request, cookies)
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end

  def authorize_test_session
    post '/users', params: { user: attributes_for(:user) }
    jar = get_cookie_jar(request, cookies)
    raise 'Authorization failed' unless jar.encrypted[:token]
  end

  def stub_authorization
    # rubocop:disable RSpec/AnyInstance
    user = build_stubbed(:user)
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(nil)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    # rubocop:enable RSpec/AnyInstance
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
