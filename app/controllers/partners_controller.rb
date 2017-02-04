class PartnersController < ApplicationController
  respond_to :html, :json
  before_action :set_partner, only: [:show, :edit, :update, :destroy]

  # POST /partners
  def create
    @partner = Partner.new(partner_params)

    if @partner.save
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { respond_with(@partner) }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: @partner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /partners/1
  def update
    if @partner.update(partner_params)
      respond_with @partner
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: @partner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /partners/1
  def destroy
    if @partner.destroy
      head :no_content
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: @partner.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_partner
      @partner = Partner.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def partner_params
      params.require(:partner).permit(:name, :type, :image, :image_cache, :summary, :bio)
    end
end
