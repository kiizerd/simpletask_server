class TasksController < ApplicationController
  before_action :set_project, except: :section_index
  before_action :set_section, only: :create

  def index
    @tasks = Task.all

    render json: @tasks
  end

  def section_index
    @tasks = Task.where(section_id: params[:section_id]).order(position: :desc)

    render json: @tasks
  end

  def show
    @task = @project.tasks.find(params[:id])

    render json: @task
  end

  def create
    task = { section: @section, position: 1, **task_params }
    @task = @project.tasks.create(task)

    if @task.save
      render json: @task
    else
      name_errors = @task.errors.full_messages_for(:name)
      render json: { name: name_errors.join("\n") }, status: :unprocessable_entity
    end
  end

  def update
    @task = @project.tasks.find(params[:id])

    if @task.update(task_params)
      render json: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @task = @project.tasks.find(params[:id])
    @task.destroy
    @tasks = @project.tasks.where(section_id: @task.section_id)

    render json: @tasks, status: :see_other
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_section
    @section = Section.find(task_params[:section_id])
  end

  def task_params
    params.require(:task).permit(:name, :details, :status, :section_id)
  end
end
