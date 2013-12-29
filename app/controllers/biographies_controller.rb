class BiographiesController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter :redirect_nyu_user
  before_filter :require_admin, :except => [:index, :show, :flvplayer, :play]
  before_filter(:only => [:index, :show]) { |c| c.active_tab=:about_us }
  before_filter :set_new_design_theme, :only => [:index, :show, :play]
  before_filter :is_biography_activated,:only => [:show]

  def index_bak
    @message_main = MarketingTextMessage.find_by_page_and_location("about_us", "main")
    @message_no_bio = MarketingTextMessage.find_by_page_and_location("about_us", "no_biography")

    @bio_message = MarketingTextMessage.find(:all,:conditions=>{:title=>"ABOUT US",:state_id => 1})
#    @biographies = Biography.find_all_by_state_id(State.find_by_name('publish').id)
#    @bryan_biography = Biography.find_by_name('bryan')
    @founder_biography = Biography.founder.published.sequence_wise.first
    @team_biographies = Biography.team.published.sequence_wise
#    @founder_biography = Biography.find_by_is_founder(true)
  end

  def index
    @biographies = Biography.for_about_us_team
    @biography = Biography.for_about_us_team.first
    @biography_link_categories = BiographyLinkCategory.published.sequence_wise
#    render :action => 'show'
  end

  def show
    @biographies = Biography.for_about_us_team
    @biography = Biography.find params[:id]
    @biography_link_categories = BiographyLinkCategory.published.sequence_wise
  end

  def display
    @biography = Biography.find params[:id]
  end

  def new
    @biography = Biography.new
  end

  def create
    add_arrow_with_links_in_description
    @biography = Biography.new(params[:biography])
    @biography.is_founder = (params[:biography][:is_founder] == "1")
    if @biography.save
      flash[:success] = "Biography successfully added."
      redirect_to list_biographies_url
    else
      render :action => 'new'
    end
  end

  def edit
    @biography = Biography.find params[:id]
  end

  def update
    @biography = Biography.find params[:id]
#    @biography.state = State.find_by_name('inactivate')
    @biography.is_founder = (params[:biography][:is_founder] == "1")
    add_arrow_with_links_in_description
    if @biography.update_attributes(params[:biography])
      flash[:notice] = "Biography updated successfully."
      redirect_to list_biographies_url
    else
      render :action => 'edit'
    end
  end

  def flvplayer
#    @video_path = params[:video_path]
#    render :layout => false
    video_path = params[:video_path]
    render :partial => 'shared/flvplayer', :locals => { :video_path => video_path, :width => '635', :height => '393', :padding => nil}
  end

  def play
    @biographies = Biography.for_about_us_team
    @biography = Biography.find params[:id]
    @biography_link_categories = BiographyLinkCategory.published.sequence_wise
  end

  def list
    @message_main = MarketingTextMessage.find_by_page_and_location("about_us", "main")
    @message_no_bio = MarketingTextMessage.find_by_page_and_location("about_us", "no_biography")
#    @founder_biography = Biography.find_by_is_founder(true)
    @biographies = Biography.sequence_wise
  end

  def publish
    biography = Biography.find params[:id]
    if biography.publish
      flash[:notice] = "Biography successfully published"
    else
      flash[:notice] = "Biography is not publishable"
    end
    return redirect_to :back
  end

  def activate
    biography = Biography.find params[:id]
    if biography.activate
      flash[:notice] = "Biography successfully activated"
    else
      flash[:notice] = "Biography is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    biography = Biography.find params[:id]
    if biography.inactivate
      flash[:notice] = "Biography successfully inactivated"
    else
      flash[:notice] = "Biography is not inactivatable"
    end
    return redirect_to :back
  end

  def move_up
    biography = Biography.find params[:id]
    if biography.move_up
      flash[:notice] = "Biography successfully moved up"
    else
      flash[:notice] = "Biography could not be moved up"
    end
    return redirect_to :back
  end

  def move_down
    biography = Biography.find params[:id]
    if biography.move_down
      flash[:notice] = "Biography successfully moved down"
    else
      flash[:notice] = "Biography could not be moved down"
    end
    return redirect_to :back
  end

  private
  def add_arrow_with_links_in_description
    # First, Make the whole Content Span-Less, to avoid Duplication of Spans
    params[:biography][:description] = params[:biography][:description].gsub('<span class="offSiteLink"></span>', "") if params[:biography][:description]
    # Append Span before Anchor for Arrow Link to appear
    params[:biography][:description] = params[:biography][:description].gsub('</a>', "<span class='offSiteLink'></span></a>") if params[:biography][:description]
  end
  def is_biography_activated
    biography = Biography.find params[:id]
    unless biography.published?
      return redirect_to about_us_path
    end
  end
end
