class TasksController < ApplicationController
  before_action :set_project, except: :section_index
  before_action :set_section, only: %i[create section_index]

  def index
    @tasks = @project.tasks

    render json: @tasks
  end

  def section_index
    @tasks = @section.tasks.order(position: :desc)

    render json: @tasks
  end

  def show
    @task = @project.tasks.find(params[:id])
    render json: @task
  rescue ActiveRecord::RecordNotFound
    @task = nil
    render json: formatted_errors
  end

  def create
    @task = @section.tasks.create(task_params.merge(project_id: @section.project_id, position: 1))

    if @task.save
      render json: @task, status: :created
    else
      render json: formatted_errors, status: :unprocessable_entity
    end
  end

  def update
    @task = @project.tasks.find(params[:id])

    if @task.update(task_params)
      render json: @task
    else
      render json: formatted_errors, status: :unprocessable_entity
    end
  end

  def destroy
    @task = @project.tasks.find(params[:id])
    @section = Section.find(@task.section_id)
    @task.destroy
    render json: @section.tasks, status: :no_content
  rescue ActiveRecord::RecordNotFound
    @task = nil
    render json: formatted_errors, status: :not_found
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render json: 'Project not found', status: :not_found
  end

  def set_section
    @section = current_user.sections.find(params[:section_id] || params[:task][:section_id])
  rescue ActiveRecord::RecordNotFound
    render json: 'Section not found', status: :not_found
  end

  def task_params
    params.require(:task).permit(:name, :details, :status, :section_id)
  end

  def formatted_errors
    super(@task)
  end
end
