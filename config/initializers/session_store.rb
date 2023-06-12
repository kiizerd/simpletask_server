Rails.application.config.session_store :cookie_store, key: 'token', domain: :all, secure: true, same_site: :none
