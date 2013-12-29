class PromoCodesController < ApplicationController
  before_filter :require_admin
  before_filter { |c| c.active_tab=:billing_tab }

  def new
    @promo_code = PromoCode.new
  end

  def create
    @promo_code = PromoCode.new(params[:promo_code])
    @promo_code.register_counter = 0
    if @promo_code.save
      flash[:notice] = 'Promotional Code created successfully'
      redirect_to promo_codes_path
    else
      render :action => 'new'
    end
  end

  def index
    @promo_codes = PromoCode.all
  end

  def destroy
    @promo_code = PromoCode.find_by_id(params[:id])
    if @promo_code.destroy
      flash[:notice] = "Deleted Successfully"
    else
      flash[:notice] = "Can not delete"
    end
    redirect_to promo_codes_path
  end

  def edit
    @promo_code = PromoCode.find_by_id(params[:id])
  end

  def update
    @promo_code = PromoCode.find_by_id(params[:id])
    if @promo_code.update_attributes(params[:promo_code])
      flash[:notice] = "Updated Successfully"
      redirect_to promo_codes_path
    else
      flash[:notice] = "Update Failed"
      render :action => 'edit'
    end
  end

  def show
    @promo_code = PromoCode.find_by_id(params[:id])
  end

end
