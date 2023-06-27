class SectionsController < ApplicationController
  before_action :set_project

  def index
    @sections = @project.sections

    render json: @sections, include: :tasks
  end

  def show
    @section = @project.sections.find(params[:id])
    render json: @section, include: :tasks
  rescue ActiveRecord::RecordNotFound
    @section = nil
    render json: formatted_errors, status: :not_found
  end

  def create
    @section = @project.sections.create(section_params)

    if @section.save
      render json: @section, status: :created
    else
      render json: formatted_errors, status: :unprocessable_entity
    end
  end

  def update
    @section = @project.sections.find(params[:id])

    if @section.update(section_params)
      render json: @section
    else
      render json: formatted_errors, status: :unprocessable_entity
    end
  end

  def destroy
    @section = @project.sections.find(params[:id])
    @tasks = Task.where(section_id: params[:id])
    @tasks.map(&:destroy)
    @section.destroy

    render json: @project.sections, status: :no_content
  rescue ActiveRecord::RecordNotFound
    @section = nil
    render json: formatted_errors, status: :not_found
  end

  def move_task
    move_params = params.require(:task).permit(:id, :index)
    @section = @project.sections.find(params[:section_id])
    task_to_move = @section.tasks.find(move_params[:id])
    new_position = @section.tasks.size - move_params[:index]
    task_to_move.insert_at(new_position)
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def section_params
    params.require(:section).permit(:name, :status)
  end

  def formatted_errors
    super(@section)
  end
end
