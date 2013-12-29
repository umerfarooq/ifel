class IndustriesController < ApplicationController
  before_filter :require_admin
  before_filter { |c| c.active_tab = :content_tab }

  def index
    @industries = Industry.state_wise
  end

  def show
    @industry = Industry.find params[:id]
  end

  def new
    @industry = Industry.new
  end

  def create
    @industry = Industry.new(params[:industry])
    @industry = Industry.new(:title => params[:industry][:title])
    if @industry.save
      flash[:notice] = "Industry successfully added."
      return redirect_to industries_path
    else
      render :action => 'new'
    end
  end

  def edit
    @industry = Industry.find params[:id]
  end

  def update
    @industry = Industry.find params[:id]
    if @industry.update_attributes(params[:industry])
      flash[:notice] = "Industry successfully updated"
      return redirect_to industries_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @industry = Industry.find params[:id]
    if @industry.destroy
      flash[:success] = "Industry is deleted."
    else
      flash[:notice] = "Industry can't be deleted."
    end
    return redirect_to :back
  end

  def publish
    @industry = Industry.find params[:id]
    if @industry.publish
      flash[:notice] = "Industry successfully published"
    else
      flash[:notice] = "industry is not publishable"
    end
    return redirect_to industries_path
  end

  def activate
    @industry = Industry.find params[:id]
    if @industry.activate
      flash[:notice] = "Industry successfully activated"
    else
      flash[:notice] = "Industry is not activatable"
    end
    return redirect_to industries_path
  end

  def inactivate
    @industry = Industry.find params[:id]
    if @industry.inactivate
      flash[:notice] = "Industry is successfully inactivated "
    else
      flash[:notice] = "Industry is not inactivatable"
    end
    return redirect_to industries_path
  end
end

