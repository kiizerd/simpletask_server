# frozen_string_literal: true

require 'rails_helper'

# Register a new user
RSpec.describe 'Users', type: :request do
  describe 'POST /users' do
    context 'with valid data' do
      let!(:new_user_email) { 'register@here.com' }

      before do
        post '/users', params: {
          user: attributes_for(:user, email: new_user_email)
        }
      end

      it 'responds with User' do
        expect(json_body[:user][:email]).to eq(new_user_email)
      end

      it 'responds with created(201) status' do
        expect(response).to have_http_status(:created)
      end

      it 'sets token cookie' do
        jar = get_cookie_jar(request, cookies)
        expect(jar.encrypted[:token]).not_to be nil
      end
    end
  end

  # Create a new session
  describe 'POST /users/sign_in' do
    let!(:existing_user_email) { 'sign@in.com' }

    before { create(:user, email: existing_user_email) }

    context 'with valid data' do
      before do
        post '/users/sign_in', params: {
          user: attributes_for(:user, email: existing_user_email)
        }
      end

      it 'responds with User' do
        expect(json_body[:user][:email]).to eq(existing_user_email)
      end

      it 'responds with created(201) status' do
        expect(response).to have_http_status(:created)
      end

      it 'sets token cookie' do
        jar = get_cookie_jar(request, cookies)
        expect(jar.encrypted[:token]).not_to be nil
      end
    end
  end

  # Deletes an existing session
  describe 'DELETE /users/sign_out' do
    context 'with authorized client' do
      before do
        authorize_test_session
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
  describe 'DELETE /users' do
    context 'with authorized client' do
      let(:email_to_delete) { 'good@bye.4ever' }

      before do
        post '/users', params: { user: attributes_for(:user, email: email_to_delete) }
        delete '/users'
      end

      it 'deletes the authenticated User' do
        expect(User.where(email: email_to_delete)).to eq []
      end

      it 'responds with no-content(204) status' do
        expect(response).to have_http_status(:no_content)
      end

      it 'removes token cookie' do
        jar = get_cookie_jar(request, cookies)
        expect(jar.encrypted[:token]).to be nil
      end
    end
  end
end
