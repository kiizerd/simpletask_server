# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sections', type: :request do
  # GET /projects/:project_id/sections -> Section#index
  describe 'GET /projects/:project_id/sections' do
    context 'with authorization and valid :project_id' do
      subject(:section) { create(:section) }

      before do
        sign_in_user(section.user.email)
        get "/projects/#{section.project_id}/sections"
      end

      it 'responds with an array' do
        expect(json_body).to be_an(Array)
      end

      it 'responds with ok(200) status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without authorization' do
      it 'responds with unauthorized(401) status' do
        get '/projects/15/sections'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # GET /projects/:project_id/sections/:id -> Section#show
  describe 'GET /projects/:project_id/sections/:id' do
    subject(:section) { create(:section) }

    context 'with authorization and requesting existing section' do
      before do
        sign_in_user(section.user.email)
        get "/projects/#{section.project_id}/sections/#{section.id}"
      end

      it 'responds with section' do
        expect(json_body[:id]).to eq(section.id)
      end

      it 'responds with ok(200) status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with authorization and requesting nonexistant section' do
      before do
        sign_in_user(section.user.email)
        get "/projects/#{section.project_id}/sections/1"
      end

      it 'responds with not_found(404) status' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without authorization' do
      it 'responds with unauthorized(401) status' do
        get '/projects/15/sections/25'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # POST /projects/:project_id/sections -> Section#create
  describe 'POST /projects/:project_id/sections' do
    let(:project) { create(:project) }
    let(:route) { "/projects/#{project.id}/sections" }

    context 'with authorized client and valid data' do
      let(:post_section) do
        params = { section: attributes_for(:section) }
        post route, params:
      end

      before { sign_in_user(project.user.email) }

      it 'creates a new section' do
        expect { post_section }.to change(Section, :count).by(1)
      end

      it 'responds with new section' do
        post_section
        expect(json_body[:name]).to eq(attributes_for(:section)[:name])
      end

      it 'responds with created(201) status' do
        post_section
        expect(response).to have_http_status(:created)
      end
    end

    context 'with authorized client and invalid data' do
      let(:post_invalid_section) do
        params = { section: attributes_for(:section, :invalid) }
        post route, params:
      end

      before { sign_in_user(project.user.email) }

      it "doesn't create new section" do
        expect { post_invalid_section }.to change(Section, :count).by(0)
      end

      it 'responds with formatted errors' do
        post_invalid_section
        expect(json_body.keys).to include(:code, :details, :messages)
      end

      it 'responds with unprocessable_entity(422) status' do
        post_invalid_section
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authorization' do
      it 'responds with unauthorized(401) status' do
        post route, params: { section: attributes_for(:section) }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # PATCH /projects/:project_id/sections/:id -> Section#update
  describe 'PATCH /projects/:project_id/sections/:id' do
    subject(:section) { create(:section) }

    let(:route) { "/projects/#{section.project_id}/sections/#{section.id}" }

    context 'with authorization and valid data' do
      let(:patch_section) do
        patch route, params: { section: { name: 'new_name' } }
      end

      before do
        sign_in_user(section.project.user.email)
        patch_section
      end

      it 'updates section' do
        updated_section = Section.find(section.id)
        expect(updated_section.name).to eq('new_name')
      end

      it 'responds with updated section' do
        expect(json_body[:name]).to eq('new_name')
      end

      it 'resonds with ok(200) status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with authorization and invalid_data' do
      let(:invalid_patch_section) do
        patch route, params: { section: { name: '' } }
      end

      before do
        sign_in_user(section.project.user.email)
        invalid_patch_section
      end

      it "doesn't update section" do
        original_section = Section.find(section.id)
        expect(original_section.name).to eq(attributes_for(:section)[:name])
      end

      it 'responds with formatted errors' do
        expect(json_body.keys).to include(:code, :details, :messages)
      end

      it 'responds with unprocessable_entity(422) status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authorization' do
      let(:patch_section) do
        patch route, params: { section: { name: 'new_name' } }
      end

      it 'responds with unauthorized(401) status' do
        patch_section
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # DELETE /projects/:project_id/sections/:id -> Section#destroy
  describe 'DELETE /projects/:project_id/sections/:id' do
    subject(:section) { create(:section) }

    let(:route) { "/projects/#{section.project_id}/sections/#{section.id}" }

    context 'when client authorized and requests valid section' do
      before { sign_in_user(section.user.email) }

      let(:delete_section) { delete route }

      it 'deletes the requested section' do
        expect { delete_section }.to change(Section, :count).by(-1)
      end

      it 'responds with no_content(204) status' do
        delete_section
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when client authorized but requests invalid section' do
      before { sign_in_user(section.user.email) }

      it 'responds with not_found(404) status' do
        delete "/projects/#{section.project.id}/sections/0"
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when client not authorized' do
      it 'responds with unauthorized(401) status' do
        delete '/projects/1/sections/1'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
