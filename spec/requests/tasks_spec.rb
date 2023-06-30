# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  #  GET /projects/:project_id/tasks -> Task#index
  describe 'GET /projects/:project_id/tasks' do
    context 'with authorization and valid project_id' do
      subject(:task) { create(:task) }

      let(:project) { task.project }

      before do
        sign_in_user(project.user.email)
        get "/projects/#{project.id}/tasks"
      end

      it 'responds with an array' do
        expect(json_body).to be_an(Array)
      end

      it 'responds with tasks belonging to project' do
        expect(json_body.size).to eq(project.tasks.count)
      end

      it 'responds with ONLY tasks belong to project' do
        create(:task)
        expect(json_body.size).not_to eq(Task.all.size)
      end

      it 'responds with ok(200) status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without authorization' do
      it 'responds with unauthorized(401) status' do
        project = create(:project)
        get "/projects/#{project.id}/tasks"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # GET /projects/:project_id/tasks/:task_id -> Task#show
  describe 'GET /projects/:project_id/tasks/:task_id' do
    context 'with auth and valid task id' do
      subject(:task) { create(:task) }

      let(:show_task) { get "/projects/#{task.project.id}/tasks/#{task.id}" }

      before do
        sign_in_user(task.project.user.email)
        show_task
      end

      it 'responds with requested task' do
        expect(json_body[:id]).to eq(task.id)
      end

      it 'responds with ok(200) status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without authorization' do
      it 'responds with unauthorized(401) status' do
        get '/projects/1/tasks/15'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # GET /projects/:project_id/sections/:section_id/tasks -> Task#section_index
  describe 'GET /projects/:project_id/sections/:section_id/tasks' do
    let(:task_data) { attributes_for(:task) }
    let(:section) do
      # Create other section
      create(:section) { |s| 3.times { s.tasks.create(task_data) } }
      # Create returned section
      create(:section) { |s| 5.times { s.tasks.create(task_data) } }
    end

    before { sign_in_user(section.project.user.email) }

    context 'with auth and valid project and section ids' do
      it 'responds with tasks belonging to requested section' do
        get "/projects/#{section.project.id}/sections/#{section.id}/tasks"

        section_tasks = Section.find(section.id).tasks
        expect(json_body.count).to eq(section_tasks.size)
      end
    end

    context 'with auth but invalid ids' do
      it 'responds with not_found(404) status' do
        get '/projects/15/sections/25/tasks'
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # POST /projects/:project_id/tasks -> Task#create
  describe 'POST /projects/:project_id/tasks' do
    let(:project) { create(:project) }
    let(:section) { project.sections.create(attributes_for(:section)) }

    context 'when authorized and request contains valid data' do
      let(:post_task) do
        params = { task: attributes_for(:task), section_id: section.id }
        post "/projects/#{project.id}/tasks", params:
      end

      before { sign_in_user(project.user.email) }

      it 'creates a new task' do
        expect { post_task }.to change(Task, :count).by(1)
      end

      it 'responds with new section' do
        post_task
        expect(json_body[:name]).to eq(attributes_for(:task)[:name])
      end

      it 'responds with created(201) status' do
        post_task
        expect(response).to have_http_status(:created)
      end
    end

    context 'when authorized but request data is invalid' do
      let(:section) { create(:section) }
      let(:task) { attributes_for(:task, :invalid) }
      let(:invalid_create_task) do
        route = "/projects/#{section.project.id}/tasks"
        params = { task:, section_id: section.id }
        post route, params:
      end

      before { sign_in_user(section.project.user.email) }

      it "doesn't create new task" do
        expect { invalid_create_task }.to change(Task, :count).by(0)
      end
    end

    context 'without authorization' do
      it 'responds with unauthorized(401) status' do
        post '/projects/1/tasks/', params: { task: { foo: 'foo' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # PATCH /projects/:project_id/tasks/:task_id -> Task#update
  describe 'PATCH /projects/:project_id/tasks/:task_id' do
    let(:project) { create(:project) }
    let(:section) { project.sections.create(attributes_for(:section)) }

    context 'with authorization and valid patch data' do
      subject(:task) do
        section.tasks.create(attributes_for(:task).merge(project_id: project.id))
      end

      before do
        sign_in_user(project.user.email)
        params = { task: { name: 'new_name' } }
        patch "/projects/#{project.id}/tasks/#{task.id}", params:
      end

      it 'updates task' do
        updated_task = Task.find(task.id)
        expect(updated_task.name).to eq('new_name')
      end

      it 'responds with updated task' do
        expect(json_body[:id]).to eq(task.id)
      end

      it 'responds with ok(200) status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with authorization but invalid data' do
      subject(:task) { create(:task) }

      let(:invalid_patch_task) do
        route = "/projects/#{task.project.id}/tasks/#{task.id}"
        params = { task: attributes_for(:task, :invalid) }
        patch route, params:
      end

      before do
        sign_in_user(task.project.user.email)
        invalid_patch_task
      end

      it "doesn't change task" do
        expect(Task.find(task.id).name).to eq(attributes_for(:task)[:name])
      end

      it 'responds with unprocessable_entity(422) status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authorization' do
      it 'responds with unauthorized(401) status' do
        patch '/projects/1/tasks/2', params: { task: attributes_for(:task) }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # DELETE /projects/:project_id/tasks/:task_id -> Task#destroy
  describe 'DELETE /projects/:project_id/tasks/:task_id' do
    context 'with authorization and valid request' do
      subject(:task) { create(:task) }

      before { sign_in_user(task.project.user.email) }

      let(:delete_task) { delete "/projects/#{task.project.id}/tasks/#{task.id}" }

      it 'deletes task' do
        expect { delete_task }.to change(Task, :count).by(-1)
      end

      it 'responds with no_content(204) status' do
        delete_task
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with authorization but and invalid request' do
      subject(:task) { create(:task) }

      it 'responds with not_found(404) status' do
        sign_in_user(task.project.user.email)
        delete("/projects/#{task.project.id}/tasks/21")

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without authorization' do
      it 'responds with unauthorized(401) status' do
        delete '/projects/1/tasks/15'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
