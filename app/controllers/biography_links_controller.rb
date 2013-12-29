class BiographyLinksController < ApplicationController
  def show
    @biography_link = BiographyLink.find params[:id]
  end

  def new
    @biography = Biography.find params[:biography_id]
    @biography_link = @biography.biography_links.build
  end

  def create
    @biography = Biography.find params[:biography_id]
    @biography_link = @biography.biography_links.build(params[:biography_link])
    @biography_link.biography_link_category = BiographyLinkCategory.find params[:biography_link][:biography_link_category_id]
#    return render :json => [params, @biography_link]
    if @biography_link.save
      flash[:notice] = "Biography Link successfully added."
      return redirect_to edit_biography_path(@biography_link.biography)
    else
      render :action => 'new'
    end
  end

  def edit
    @biography = Biography.find params[:biography_id]
    @biography_link = BiographyLink.find params[:id]
  end

  def update
    @biography = Biography.find params[:biography_id]
    @biography_link = BiographyLink.find params[:id]
    if @biography_link.update_attributes(params[:biography_link])
      flash[:notice] = "Biography Link updated successfully."
      return redirect_to edit_biography_path(@biography_link.biography)
    else
      render :action => 'edit'
    end
  end

  def publish
    biography_link = BiographyLink.find params[:id]
    if biography_link.publish
      flash[:notice] = "Biography Link successfully published"
    else
      flash[:notice] = "Biography Link is not publishable"
    end
    redirect_to edit_biography_path(biography_link.biography)
  end

  def activate
    biography_link = BiographyLink.find params[:id]
    if biography_link.activate
      flash[:notice] = "Biography Link successfully activated"
    else
      flash[:notice] = "Biography Link is not activatable"
    end
    redirect_to edit_biography_path(biography_link.biography)
  end

  def inactivate
    biography_link = BiographyLink.find params[:id]
    if biography_link.inactivate
      flash[:notice] = "Biography Link successfully inactivated"
    else
      flash[:notice] = "Biography Link is not inactivatable"
    end
    redirect_to edit_biography_path(biography_link.biography)
  end

  def move_up
    biography_link = BiographyLink.find params[:id]
    if biography_link.move_up
      flash[:notice] = "Biography Link successfully moved up"
    else
      flash[:notice] = "Biography Link could not be moved up"
    end
    redirect_to edit_biography_path(biography_link.biography)
  end

  def move_down
    biography_link = BiographyLink.find params[:id]
    if biography_link.move_down
      flash[:notice] = "Biography Link successfully moved down"
    else
      flash[:notice] = "Biography Link could not be moved down"
    end
    redirect_to edit_biography_path(biography_link.biography)
  end

end
