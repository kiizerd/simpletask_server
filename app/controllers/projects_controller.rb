class ProjectsController < ApplicationController
  def index
    @projects = current_user.projects.where(user_id: @current_user.id)

    render json: @projects, include: [sections: { include: :tasks }]
  end

  def show
    @project = current_user.projects.find(params[:id])

    render json: @project, include: [sections: { include: :tasks }]
  end

  def create
    @project = current_user.projects.create(project_params)

    if @project.save
      render json: @project
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def update
    @project = current_user.projects.find(params[:id])

    if @project.update(project_params)
      render json: @project
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @project = current_user.projects.find(params[:id])
    @project.tasks.map(&:destroy)
    @project.sections.map(&:destroy)
    @project.destroy

    render json: current_user.projects, status: :see_other
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :status)
  end

  def belongs_to_current_user?
    @current_user.id
  end
end
