class TasksController < ApplicationController
  before_action :set_project, except: :section_index

  def index
    @tasks = Task.all

    render json: @tasks
  end

  def section_index
    @tasks = Task.where(section_id: params[:section_id])

    render json: @tasks
  end

  def show
    @task = @project.tasks.find(params[:id])

    render json: @task
  end

  def create
    @task = @project.tasks.create(task_params)

    if @task.save
      render json: @task
    else
      render json: @task.errors, status: :unprocessable_entity
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

  def task_params
    params.require(:task).permit(:name, :details, :status, :section_id)
  end
end
