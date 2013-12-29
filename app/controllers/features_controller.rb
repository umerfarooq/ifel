class FeaturesController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter :redirect_nyu_user
  before_filter { |c| c.active_tab=:features }
  before_filter :set_new_design_theme, :only => [:index, :show, :detail, :pricing, :why_wicked_start]
  before_filter :require_admin, :except => [:index, :show, :detail, :pricing, :why_wicked_start, :flvplayer]
  before_filter :load_videos, :only => [:detail, :why_wicked_start]

  def new
    @feature = Feature.new
  end

  def index
    @features = Feature.for_index
    @success_stories = (SuccessStory.published.logo_exists | SuccessStory.featured.logo_exists).shuffle[1..3]
  end

  def edit
    @feature = Feature.find params[:id]
  end

  def update
    @feature = Feature.find params[:id]
    #    @feature.state = State.find_by_name('inactivate')
    if @feature.update_attributes(params[:feature])
      flash[:notice] = "Feature updated successfully."
      if @feature.parent.blank?
        redirect_to list_features_url
      else
        redirect_to edit_feature_path(@feature.parent, :is_parent => true)
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
  end

  def create
    @feature = Feature.new(params[:feature])
    @feature.parent_id = params[:feature][:parent_id]
    if @feature.save
      flash[:success] = "Feature successfully added."
      if @feature.parent.blank?
        redirect_to list_features_url
      else
        redirect_to edit_feature_path(@feature.parent, :is_parent => true)
      end
    else
      render :action => 'new'
    end
  end

  def show
    @feature = Feature.find_by_id(params[:id])
    return render :partial => "feature", :locals => {:child => @feature, :parent => @feature.parent}
  end

  def detail    
    @features = Feature.get_parents.published.sequence_wise
    @selected_feature = Feature.find_by_id(params[:id])
    @first_child = @selected_feature.children.published.sequence_wise.first
  end

  def pricing
    if $is_ws_free_as_default
      redirect_to features_path
    end
  end

  def why_wicked_start
    @open_video = (params[:video]=='true') ? true : false   
    @promotions = Promotion.feature_kind_of.published
    @why_wicked_start_page = MarketingTextMessage.find_by_page_and_location('why_wicked_start', 'main')
  end

  #################################################################
  def flvplayer
#    @video_path = params[:video_path]
#    render :layout => false
    video_path = params[:video_path]
    render :partial => 'shared/flvplayer', :locals => { :video_path => video_path, :width => nil, :height => nil, :padding => nil }
  end

  def list
    @features = Feature.roots.sort_by { |obj| obj.sequence_number  }
    @why_wicked_start_page = MarketingTextMessage.find_by_page_and_location('why_wicked_start', 'main')
  end

  def publish
    feature = Feature.find params[:id]
    if feature.publish
      flash[:notice] = "Feature successfully published"
    else
      flash[:notice] = "Feature is not publishable"
    end
    return redirect_to :back
  end

  def activate
    feature = Feature.find params[:id]
    if feature.activate
      flash[:notice] = "Feature successfully activated"
    else
      flash[:notice] = "Feature is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    feature = Feature.find params[:id]
    if feature.inactivate
      flash[:notice] = "Feature successfully inactivated"
    else
      flash[:notice] = "Feature is not inactivatable"
    end
    return redirect_to :back
  end

  def move_up
    feature = Feature.find params[:id]
    if feature.move_up
      flash[:notice] = "Feature successfully moved up"
    else
      flash[:notice] = "Feature could not be moved up"
    end
    return redirect_to :back
  end

  def move_down
    feature = Feature.find params[:id]
    if feature.move_down
      flash[:notice] = "Feature successfully moved down"
    else
      flash[:notice] = "Feature could not be moved down"
    end
    return redirect_to :back
  end
  
  private
  
  def load_videos
    @multimedia = MarketingMultimediaMessage.find_by_page('why_wicked_start','main')
    @how_it_works = MarketingMultimediaMessage.find_by_page_and_location('how_it_works','take_a_tour')
  end

end
