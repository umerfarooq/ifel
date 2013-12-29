class PromotionsController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
#  before_filter(:only => [:index, :show]) { |c| c.active_tab=:about_us }
  before_filter { |c| c.active_tab=:content_tab }
  before_filter :require_admin, :except => [:update_promotion_box]

  def display
    @promotion = Promotion.find params[:id]
  end

  def new
    @promotion = Promotion.new
  end

  def create
    @promotion = Promotion.factory(params[:promotion])
#    @promotion = Promotion.new(params[:promotion])
    if @promotion.save
      flash[:notice] = "Promotion successfully added."
      return redirect_to list_news_articles_url
    else
      @error_messages = @promotion.errors
      render :action => 'new'
    end
  end

  def edit
    @promotion = Promotion.find params[:id]
  end

  def update
    # Change the Sub-Class type
    previously_persisted_kind_of_promotion = Promotion.reconstruct_promotion_and_get_persisted_kind params
    @promotion = Promotion.find(params[:id])
    # Run-time construction of Promotion Object,
    # according to specific Child Class (Regular/Partner/Feature promotion)
    @promotion = @promotion.becomes(@promotion.kind.constantize)    
    if @promotion.update_attributes(params[:promotion])
      flash[:notice] = "Promotion updated successfully."
      return redirect_to list_news_articles_url
    else
      # Moving promotion back to the original Child Object type, on Validations failed
      @promotion.update_attribute(:kind, previously_persisted_kind_of_promotion)
      @error_messages = @promotion.errors
      render :action => 'edit'
    end
  end
  
  def destroy
    @promotion = Promotion.find(params[:id])
    if @promotion.destroy
      flash[:success] = "Promotion is deleted."
    else
      flash[:notice] = "Promotion can't be deleted."
    end
    return redirect_to :back
  end

  def update_promotion_box
    @promotion = Promotion.next_promotion(params[:id]).first rescue nil
    if @promotion.blank?
      @promotion = Promotion.find params[:id]
    end
    return render :partial=>"promotions/promotion", :locals=>{:promotion=>@promotion}
  end

  def publish
    promotion = Promotion.find params[:id]
    if promotion.publish
      flash[:notice] = "Promotion successfully published"
    else
      flash[:notice] = "Promotion is not publishable"
    end
    redirect_to list_news_articles_url
  end

  def featurify
    promotion = Promotion.find params[:id]
    if promotion.featurify
      flash[:notice] = "Promotion successfully featurified"
    else
      flash[:notice] = "Promotion is not featurifiable"
    end
    redirect_to list_news_articles_url
  end

  def activate
    promotion = Promotion.find params[:id]
    if promotion.activate
      flash[:notice] = "Promotion successfully activated"
    else
      flash[:notice] = "Promotion is not activatable"
    end
    redirect_to list_news_articles_url
  end

  def inactivate
    promotion = Promotion.find params[:id]
    if promotion.inactivate
      flash[:notice] = "Promotion successfully inactivated"
    else
      flash[:notice] = "Promotion is not inactivatable"
    end
    redirect_to list_news_articles_url
  end
end
