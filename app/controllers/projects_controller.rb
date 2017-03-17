class ProjectsController < ApplicationController
  respond_to :html, :json
  skip_before_action :authenticate_user!, only: [:show, :index]
  before_action :set_project, only: [:show, :edit, :update, :destroy, :add_category, :remove_category]

  # POST /projects
  def show
    respond_to do |format|
      format.html { redirect_to root_path(anchor: @project.slug) }
      format.json { respond_with(@project) }
    end
  end

  # POST /projects/1/add_category?category_id=1
  def add_category
    @project_category = ProjectCategory.find_or_create_by(project: @project, category_id: params[:category_id])

    respond_to do |format|
      format.html { redirect_to root_path(anchor: @project.slug) }
      format.json { respond_with(@project_category) }
    end
  end

  # POST /projects/1/remove_category?category_id=1
  def remove_category
    @project_category = ProjectCategory.find_by(project: @project, category_id: params[:category_id])
    @project_category.destroy if @project_category

    respond_to do |format|
      format.html { redirect_to root_path(anchor: @project.slug) }
      format.json { respond_with(@project) }
    end
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      respond_to do |format|
        format.html { redirect_to root_path(anchor: @project.slug) }
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
        format.html { redirect_to root_path(anchor: @project.slug) }
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
      params.require(:project).permit(:name, :type, :image, :image_cache, :thumb_image, :thumb_image_cache, :summary, :sort_order, selected_categories: [])
    end
end
