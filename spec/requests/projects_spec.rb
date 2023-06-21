# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Projects', type: :request do
  # GET /projects - Projects#index
  describe 'GET /projects' do
    context 'with authorization' do
      before do
        # Create 3 projects as authorized user
        authorize_test_session
        3.times do
          post '/projects', params: { project: attributes_for(:project) }
        end
        # Create 2 projects as a new user
        create(:user) do |user|
          2.times { user.projects.create(attributes_for(:project)) }
        end
      end

      it 'responds with only current users projects' do
        get '/projects'
        expect(json_body[:projects].count).to eq(3)
      end
    end

    context 'without authorization' do
      it 'responds with an unauthorized(401) status' do
        get '/projects'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # GET /projects/:id - Projects#show
  describe 'GET /projects/:id' do
    context 'when authorized client requests existing project' do
      before do
        authorize_test_session
        post '/projects', params: { project: attributes_for(:project) }
      end

      it 'responds with Project matching :id' do
        project_id = json_body[:id]
        get "/projects/#{project_id}"
        expect(json_body[:id]).to eq(project_id)
      end

      it 'responds with ok(200) status' do
        get "/projects/#{json_body[:id]}"
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when authorized client requests nonexistant project' do
      before { authorize_test_session }

      it 'responds with not_found(404) status' do
        get '/projects/1337'
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when client is not authorized' do
      it 'responds with unauthorized(401) status' do
        get '/projects/1337'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # POST /projects - Projects#create
  describe 'POST /projects' do
    context 'when client is authorized and sent valid data' do
      before { authorize_test_session }

      let(:valid_request) { post('/projects', params: { project: attributes_for(:project) }) }

      it 'creates a new Project' do
        expect { valid_request }.to change(Project, :count).by(1)
      end

      it 'responds with created(201) status' do
        valid_request
        expect(response).to have_http_status(:created)
      end

      it 'responds with Project' do
        valid_request
        expect(json_body[:title]).to eq(attributes_for(:project)[:title])
      end
    end

    context 'when client is authorized but data is invalid' do
      before { authorize_test_session }

      let(:invalid_request) { post('/projects', params: { project: attributes_for(:project, :invalid) }) }

      it "doesn't create new Project" do
        expect { invalid_request }.to change(Project, :count).by(0)
      end

      it 'responds with a unprocessable_entity(422) status' do
        invalid_request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'responds with helpful errors' do
        invalid_request
        expect(json_body.keys).to include(:code, :details, :messages)
      end
    end

    context 'when client is not authorized' do
      let(:unauthorized_request) { post '/projects', params: { project: attributes_for(:project) } }

      it 'responds with unauthorized(401) status' do
        unauthorized_request
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # PATCH /projects/:id - Projects#update
  describe 'PATCH /projects/:id' do
    context 'when client is authorized and sends valid data' do
      before do
        authorize_test_session
        post '/projects', params: { project: attributes_for(:project) }
        project_id = json_body[:id]
        patch "/projects/#{project_id}", params: { project: { title: 'new_title' } }
      end

      it 'responds with the updated project' do
        expect(json_body[:title]).to eq('new_title')
      end

      it 'respondes with ok(200) status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when client is authorized but data is invalid' do
      before do
        authorize_test_session
        post '/projects', params: { project: attributes_for(:project) }
        project_id = json_body[:id]
        patch "/projects/#{project_id}", params: { project: { title: 'z' } }
      end

      it "doesn't update Project" do
        project_id = request.fullpath.split('/').last.to_i
        project = Project.find(project_id)
        expect(project.title).to eq(attributes_for(:project)[:title])
      end

      it 'responds with a unprocessable_entity(422) status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'responds with helpful errors' do
        expect(json_body.keys).to include(:code, :details, :messages)
      end
    end

    context 'when client is not authorized' do
      it 'responds with unauthorized(401) status' do
        patch '/projects/1337', params: { project: { email: 'not@gonna.happen' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # DELETE /projects/:id - Projects#destroy
  describe 'DELETE /projects/:id' do
    context 'when client is authorized and requests existing project' do
      before do
        authorize_test_session
        post '/projects', params: { project: attributes_for(:project) }
      end

      it 'deletes the requested project' do
        expect { delete "/projects/#{json_body[:id]}" }.to change(Project, :count).by(-1)
      end

      it 'responds with no_content(204) status' do
        delete "/projects/#{json_body[:id]}"
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when client is authorized but requests nonexistant project' do
      before { authorize_test_session }

      it 'responds with not_found(404) status' do
        delete '/projects/1'
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without authorization' do
      it 'responds with unauthorized(401) status' do
        delete '/projects/1'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
