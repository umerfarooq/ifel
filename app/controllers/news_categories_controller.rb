class NewsCategoriesController < ApplicationController
  def new
    @news_category = NewsCategory.new
  end

  def edit
    @news_category = NewsCategory.find_by_id(params[:id])
  end

  def update
    @news_category = NewsCategory.find_by_id(params[:id])
    if @news_category.update_attributes(params[:news_category])
      flash[:notice] = "News Category successfully updated."
      redirect_to '/admins/radar_tab'
    else
      render :action => 'edit'
    end
  end

  def create
    @news_category = NewsCategory.new(params[:news_category])
    if @news_category.save
      flash[:notice] = "News Category successfully added."
      redirect_to '/admins/radar_tab'
    else
      render :action => 'edit'
    end
  end

  def destroy
  end

  def index
  end

  def show
  end
  #################################################################################################
  #################################################################################################
  #################################################################################################

  def change_state
    @news_category = NewsCategory.find_by_id(params[:id])
    @news_category.state = State.find_by_title(params[:state])
    if @news_category.save
    else
    end
    redirect_to '/admins/radar_tab'
  end

end
