class SectionsController < ApplicationController
  before_action :set_project

  def index
    @sections = @project.sections

    render json: @sections, include: :tasks
  end

  def show
    @section = @project.sections.find(params[:id])

    render json: @section, include: :tasks
  end

  def create
    @section = @project.sections.create(section_params)

    if @section.save
      render json: @section
    else
      render json: @section.errors, status: :unprocessable_entity
    end
  end

  def update
    @section = @project.sections.find(params[:id])

    if @section.update(section_params)
      render json: @section
    else
      render json: @section.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @section = @project.sections.find(params[:id])
    @tasks = Task.where(section_id: params[:id])
    @tasks.map(&:destroy)
    @section.destroy

    render json: @project.sections, status: :see_other
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def section_params
    params.require(:section).permit(:name, :status)
  end
end
