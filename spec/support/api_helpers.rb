module ApiHelpers
  def json_body
    JSON.parse(response.body).deep_symbolize_keys
  end

  def get_cookie_jar(request, cookies)
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
