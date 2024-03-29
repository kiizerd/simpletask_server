# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

to_regexp = ->(string) { Regexp.new(string) }
hosts = [
  *ENV.fetch('ALLOWED_ORIGINS', nil)&.split(', '),
  *ENV.fetch('ALLOWED_ORIGINS_REGEXPS', nil)&.split(';')&.map(&to_regexp)
].compact

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Vite dev server at 5173, and production url
    origins(*hosts)

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true
  end
end
