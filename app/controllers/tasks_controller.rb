class TasksController < ApplicationController
  before_action :set_project

  def index
    @tasks = Task.all

    render json: @tasks
  end

  def show
    # @task = Task.find(params[:id])
    @task = @project.tasks.find(params[:id])

    render json: @task
  end

  def create
    # @task = Task.new(task_params)
    @task = @project.tasks.create(task_params)

    if @task.save
      render json: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def update
    # @task = Task.find(params[:id])
    @task = @project.tasks.find(params[:id])

    if @task.update(task_params)
      render json: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def destroy
    # @task = Task.find(params[:id])
    @task = @project.tasks.find(params[:id])
    @task.destroy

    # render json: Task.all, status: :see_other
    render json: @project, status: :see_other
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def task_params
    params.require(:task).permit(:name, :details)
  end
end
