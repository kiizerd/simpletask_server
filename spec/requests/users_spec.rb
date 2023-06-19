require 'rails_helper'

# Register a new user
RSpec.describe 'POST /users/', type: :request do
  context 'client submitted valid data' do
    before do
      user_data = { email: 'foo@bar.com', password: 'password' }

      post '/users', params: { user: user_data }
    end

    it 'responds with the correct status(201) and new User' do
      user = json_body[:user]
      expect(response).to have_http_status(:created)
      expect(user[:email]).to eq('foo@bar.com')
    end

    it 'sets token cookie' do
      jar = get_cookie_jar(request, cookies)
      expect(jar.encrypted[:token]).not_to be nil
    end
  end
end

# Create a new session
RSpec.describe 'POST /users/sign_in', type: :request do
  before { User.create(email: 'foo@bar.com', password: 'password') }

  context 'client submitted valid data' do
    before do
      user_data = { email: 'foo@bar.com', password: 'password' }

      post '/users/sign_in', params: { user: user_data }
    end

    it 'responds with correct status(201) and User' do
      expect(response).to have_http_status(:created)
      expect(json_body[:user][:email]).to eq('foo@bar.com')
    end

    it 'sets token cookie' do
      jar = get_cookie_jar(request, cookies)
      expect(jar.encrypted[:token]).not_to be nil
    end
  end
end

# Deletes an existing session
RSpec.describe 'DELETE /users/sign_out', type: :request do
  before { User.create(email: 'foo@bar.com', password: 'password') }

  context 'client is authorized' do
    before do
      user_data = { email: 'foo@bar.com', password: 'password' }

      post '/users/sign_in', params: { user: user_data }
      delete '/users/sign_out'
    end

    it 'responds with no-content(204) status code' do
      expect(response).to have_http_status(:no_content)
    end

    it 'removes token cookie' do
      jar = get_cookie_jar(request, cookies)
      expect(jar.encrypted[:token]).to be nil
    end
  end
end

# Deletes a User model
RSpec.describe 'DELETE /users', type: :request do
  let(:user_data) { { email: 'foo@bar.com', password: 'password' } }
  before do
    post '/users', params: { user: user_data }
    delete '/users'
  end

  it 'deletes the authenticated User' do
    expect(User.where(email: user_data[:email])).to eq []
  end

  it 'responds with no content status' do
    expect(response).to have_http_status(:no_content)
  end

  it 'removes token cookie' do
    jar = get_cookie_jar(request, cookies)
    expect(jar.encrypted[:token]).to be nil
  end
end
