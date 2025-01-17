class BulkDiscountsController < ApplicationController
  before_action :find_merchant
  before_action :find_bulk_discount, only: [:destroy, :show, :edit, :update]
  
  def index
    @bulk_discounts = @merchant.bulk_discounts
    @holidays = NagerFacade.new.holidays
  end

  def show
  end

  def new
    @bulk_discount = @merchant.bulk_discounts.new
  end

  def create
    @bulk_discount = @merchant.bulk_discounts.new(bulk_discount_params)

    if @bulk_discount.save
      flash[:notice] = "New bulk discount added"
      redirect_to merchant_bulk_discounts_path(params[:merchant_id])
    else
      flash[:notice] = "Invalid form: Unable to create Bulk Discount"
 
      render :new
    end
  end

  def edit
    # if @bulk_discount.pending_invoice?
    #   flash[:notice] = "Unable to Edit Discount: This discount currently belongs to a pending invoice"
    #   redirect_to merchant_bulk_discount_path(@merchant, @bulk_discount)
    # end
  end

  def update
    @bulk_discount.update(bulk_discount_params)

    if @bulk_discount.save
      flash[:notice] = "Bulk Discount Edited"
      redirect_to merchant_bulk_discount_path(@merchant, @bulk_discount)
    else
      flash[:notice] = "Invalid form: Unable to update Bulk Discount"
 
      render :edit
    end
  end

  def destroy
    # if @bulk_discount.pending_invoice?
    #   flash[:notice] = "Unable to Delete Discount: This discount currently belongs to a pending invoice"
    #   redirect_to merchant_bulk_discounts_path(@merchant)
    # else
    @bulk_discount.destroy

    redirect_to merchant_bulk_discounts_path(params[:merchant_id])
    # end
  end
  
  private
  def bulk_discount_params
    params.require(:bulk_discount).permit(:quantity_threshold, :percentage_discount)
  end

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def find_bulk_discount
    @bulk_discount = BulkDiscount.find(params[:id])
  end
end