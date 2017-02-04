class CustomersController < ApplicationController
  respond_to :html, :json
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # POST /customers
  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { respond_with(@customer) }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  def update
    if @customer.update(customer_params)
      respond_with @customer
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  def destroy
    if @customer.destroy
      head :no_content
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def customer_params
      params.require(:customer).permit(:name, :type, :image, :image_cache, :summary, :bio)
    end
end
