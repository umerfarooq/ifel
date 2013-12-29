class WhitePapersController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
#  before_filter :redirect_nyu_user
  before_filter :require_admin, :except => [:index, :download]
  #before_filter(:only => [:index]) { |c| c.active_tab=:on_the_radar }
  before_filter { |c| c.active_tab=:content_tab }
  before_filter :set_new_design_theme, :only => [:index]

  def index
    @message_main = MarketingTextMessage.find_by_page_and_location("on_the_radar", "main")
    @message_no_wp = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_white_paper")
    if current_user.blank?
      @white_papers = WhitePaper.published.for_public.sequence_wise
    else
      @white_papers = WhitePaper.published.sequence_wise
    end
    @upcomming_events = Event.aboutus_sidebar_events
  end

  def new
    @white_paper = WhitePaper.new
  end

  def create
    @white_paper = WhitePaper.new(params[:white_paper])
    @white_paper.is_internal = (params[:white_paper][:is_internal] == "1")
    if @white_paper.save
      flash[:notice] = "White paper successfully added."
      return redirect_to list_news_articles_url
    else
      render :action => 'new'
    end
  end

  def edit
    @white_paper = WhitePaper.find params[:id]
  end

  def update
    @white_paper = WhitePaper.find params[:id]
    @white_paper.is_internal = (params[:white_paper][:is_internal] == "1") unless params[:white_paper][:is_internal].blank?
#    @white_paper.state = State.find_by_name('inactivate')
    if @white_paper.update_attributes(params[:white_paper])
      flash[:notice] = "White paper successfully updated."
      return redirect_to list_news_articles_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @white_paper = WhitePaper.find params[:id]
    if @white_paper.destroy
      flash[:success] = "White paper is deleted."
    else
      flash[:notice] = "White paper can't be deleted."
    end
    return redirect_to :back
  end

  def publish
    white_paper = WhitePaper.find params[:id]
    if white_paper.publish
      flash[:notice] = "White Paper successfully published"
    else
      flash[:notice] = "White Paper is not publishable"
    end
    return redirect_to :back
  end

  def activate
    white_paper = WhitePaper.find params[:id]
    if white_paper.activate
      flash[:notice] = "White Paper successfully activated"
    else
      flash[:notice] = "White Paper is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    white_paper = WhitePaper.find params[:id]
    if white_paper.inactivate
      flash[:notice] = "White Paper successfully inactivated"
    else
      flash[:notice] = "White Paper is not inactivatable"
    end
    return redirect_to :back
  end

  def move_up
    white_paper = WhitePaper.find params[:id]
    if white_paper.move_up
      flash[:notice] = "White Paper successfully moved up"
    else
      flash[:notice] = "White Paper could not be moved up"
    end
    return redirect_to :back
  end

  def move_down
    white_paper = WhitePaper.find params[:id]
    if white_paper.move_down
      flash[:notice] = "White Paper successfully moved down"
    else
      flash[:notice] = "White Paper could not be moved down"
    end
    return redirect_to :back
  end

  def download
    #    filename = params[:filename]
    # http://thewebfellas.com/blog/2009/8/29/protecting-your-paperclip-downloads
    white_paper = WhitePaper.find_by_id(params[:id])
    head(:not_found) and return if (white_paper.nil? || white_paper.not_published?)
    head(:forbidden) and return if (white_paper.internal? && current_user.blank?)
    send_file_options = { :type => MIME::Types.type_for(white_paper.paper.path) }
    send_file(white_paper.paper.path, send_file_options)
  end

end
