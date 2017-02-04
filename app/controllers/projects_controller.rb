class ProjectsController < ApplicationController
  respond_to :html, :json
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { respond_with(@project) }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      respond_with @project
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  def destroy
    if @project.destroy
      head :no_content
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def project_params
      params.require(:project).permit(:name, :type, :image, :image_cache, :summary)
    end
end
