class ProjectsController < ApplicationController
  def index
    @projects = current_user.projects

    render json: { projects: @projects }, include: [sections: { include: :tasks }]
  end

  def show
    @project = current_user.projects.find(params[:id])
    render json: @project, include: [sections: { include: :tasks }]
  rescue ActiveRecord::RecordNotFound
    @project = nil
    render json: formatted_errors, status: :not_found
  end

  def create
    @project = current_user.projects.create(project_params)

    if @project.save
      render json: @project, status: :created
    else
      render json: formatted_errors, status: :unprocessable_entity
    end
  end

  def update
    @project = current_user.projects.find(params[:id])

    if @project.update(project_params)
      render json: @project
    else
      render json: formatted_errors, status: :unprocessable_entity
    end
  end

  def destroy
    @project = current_user.projects.find(params[:id])
    @project.tasks.map(&:destroy)
    @project.sections.map(&:destroy)
    @project.destroy

    render json: current_user.projects, status: :no_content
  rescue ActiveRecord::RecordNotFound
    @project = nil
    render json: formatted_errors, status: :not_found
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :status)
  end

  def belongs_to_current_user?
    @current_user.id
  end

  def formatted_errors
    super(@project)
  end
end
