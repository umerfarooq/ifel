class SuccessStoriesController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter :redirect_nyu_user
  before_filter :require_admin, :except => [:index, :show]
  before_filter { |c| c.active_tab=:success_stories }
  before_filter :set_new_design_theme, :only => [:index, :show]

  def index
#    @success_stories_message = MarketingTextMessage.find(:all,:conditions=>{:title=>"READ OUR LATEST SUCCESS STORIES",:state_id => 1})
    @message_main = MarketingTextMessage.find_by_page_and_location("success_stories", "main")
#    @message_no_ss = MarketingTextMessage.find_by_page_and_location("success_stories", "no_success_story")
    @success_stories = SuccessStory.sequence_wise.publically_available
#    @success_stories = SuccessStory.find_all_by_state_id(State.find_by_name('publish').id, :order => 'sequence_number ASC')
  end

  def show
    @success_story = SuccessStory.find params[:id]
  end

  def new
    @success_story = SuccessStory.new
  end

  def create
    @success_story = SuccessStory.new(params[:success_story])
    @success_story.industry_id = params[:success_story][:industry_id]
    @success_story.is_logo = (params[:success_story][:is_logo] == "1")
    if @success_story.save
      flash[:notice] = "Success Story successfully added."
      return redirect_to list_success_stories_url
    else
      render :action => 'new'
    end
  end

  def edit
    @success_story = SuccessStory.find params[:id]
  end

  def update
#        return render :xml => params
    @success_story = SuccessStory.find params[:id]
    @success_story.industry_id = params[:success_story][:industry_id]
    @success_story.is_logo = (params[:success_story][:is_logo] == "1") unless params[:success_story][:is_logo].blank?
    if @success_story.update_attributes(params[:success_story])
      flash[:notice] = "Success Story updated successfully."
      return redirect_to list_success_stories_url
    else
      render :action => 'edit'
    end
  end

  def list
    @success_stories_message = MarketingTextMessage.find(:all,:conditions=>{:title=>"READ OUR LATEST SUCCESS STORIES",:state_id => 1})
    @message_main = MarketingTextMessage.find_by_page_and_location("success_stories", "main")
    @message_no_ss = MarketingTextMessage.find_by_page_and_location("success_stories", "no_success_story")
#    @message_success_stories = MarketingTextMessage.find_by_page_and_location("success_stories", "success_stories")
    @success_stories = SuccessStory.all(:order => 'sequence_number ASC')
  end

  def featurify
    success_story = SuccessStory.find params[:id]
    if success_story.featurify
      flash[:notice] = "Success Story successfully featurified"
    else
      flash[:notice] = "Success Story is not featurifiable"
    end
    redirect_to list_success_stories_url
  end

  def publish
    success_story = SuccessStory.find params[:id]
    if success_story.publish
      flash[:notice] = "Success Story successfully published"
    else
      flash[:notice] = "Success Story is not publishable"
    end
    redirect_to list_success_stories_url
  end

  def activate
    success_story = SuccessStory.find params[:id]
    if success_story.activate
      flash[:notice] = "Success Story successfully activated"
    else
      flash[:notice] = "Success Story is not activatable"
    end
    redirect_to list_success_stories_url
  end

  def inactivate
    success_story = SuccessStory.find params[:id]
    if success_story.inactivate
      flash[:notice] = "Success Story successfully inactivated"
    else
      flash[:notice] = "Success Story is not inactivatable"
    end
    redirect_to list_success_stories_url
  end

  def move_up
    success_story = SuccessStory.find params[:id]
    if success_story.move_up
      flash[:notice] = "Success Story successfully moved up"
    else
      flash[:notice] = "Success Story could not be moved up"
    end
    redirect_to list_success_stories_url
  end

  def move_down
    success_story = SuccessStory.find params[:id]
    if success_story.move_down
      flash[:notice] = "Success Story successfully moved down"
    else
      flash[:notice] = "Success Story could not be moved down"
    end
    redirect_to list_success_stories_url
  end

end
