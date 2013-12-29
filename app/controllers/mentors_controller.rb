class MentorsController < ApplicationController
  before_filter :require_admin, :except => :show
  before_filter :require_user, :only => :show
  before_filter { |c| c.active_tab=:content_tab }
  before_filter(:only => [:show]) { |c| c.active_tab=:startup_workspace }
  before_filter :set_new_design_theme, :only => :show
  #  before_filter(:only => [:show]) { |c| c.active_tab=:mentor }
  #  before_filter { |c| c.active_tab=:startup_workspace }
  
  # GET /mentors
  # GET /mentors.xml
  def index
    @mentors = Mentor.name_wise(params[:d] || 'asc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mentors }
    end
  end

  # GET /mentors/1
  # GET /mentors/1.xml
  def show
    @mentor = @current_user.mentor rescue nil

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mentor }
    end
  end

  # GET /mentors/new
  # GET /mentors/new.xml
  def new
    @mentor = Mentor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mentor }
    end
  end

  # GET /mentors/1/edit
  def edit
    @mentor = Mentor.find(params[:id])
  end

  # POST /mentors
  # POST /mentors.xml
  def create
    @mentor = Mentor.new(params[:mentor])

    respond_to do |format|
      if @mentor.save
        format.html { redirect_to(mentors_url, :notice => 'Mentor was successfully created.') }
        format.xml  { render :xml => @mentor, :status => :created, :location => @mentor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mentor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mentors/1
  # PUT /mentors/1.xml
  def update
    @mentor = Mentor.find(params[:id])

    respond_to do |format|
      if @mentor.update_attributes(params[:mentor])
        format.html { redirect_to(mentors_url, :notice => 'Mentor was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mentor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mentors/1
  # DELETE /mentors/1.xml
  def destroy
    @mentor = Mentor.find(params[:id])
    @mentor.destroy

    respond_to do |format|
      format.html { redirect_to(mentors_url) }
      format.xml  { head :ok }
    end
  end
  
  def publish
    mentor = Mentor.find params[:id]
    if mentor.publish
      flash[:notice] = "Mentor successfully published"
    else
      flash[:notice] = "Mentor is not publishable"
    end
    return redirect_to :back
  end

  def activate
    mentor = Mentor.find params[:id]
    if mentor.activate
      flash[:notice] = "Mentor successfully activated"
    else
      flash[:notice] = "Mentor is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    mentor = Mentor.find params[:id]
    if mentor.inactivate
      flash[:notice] = "Mentor successfully inactivated"
    else
      flash[:notice] = "Mentor is not inactivatable"
    end
    return redirect_to :back
  end
  
  def associate_user
    @mentor = Mentor.find params[:id]
    if params[:c]
      case params[:c] 
      when 'first_name'
        @industry_based_users = User.without_mentor.with_industries(@mentor.industry_ids).first_name_wise(params[:d])    
        @industry_less_users = User.without_mentor.without_industry.first_name_wise(params[:d])
      when 'industry'
        @industry_based_users = User.without_mentor.with_industries(@mentor.industry_ids).industry_wise(params[:d])    
        @industry_less_users = User.without_mentor.without_industry.industry_wise(params[:d])
      when 'business_idea'
        @industry_based_users = User.without_mentor.with_industries(@mentor.industry_ids).business_idea_wise(params[:d])    
        @industry_less_users = User.without_mentor.without_industry.business_idea_wise(params[:d])      
      end
    else
      @industry_based_users = User.without_mentor.with_industries(@mentor.industry_ids).name_wise('asc')    
      @industry_less_users = User.without_mentor.without_industry.name_wise('asc')
    end    
  end
  
  def update_user_association
    @mentor = Mentor.find params[:id]
    params[:mentor] ||= { :user_ids => [] }
    if @mentor.update_attribute(:user_ids, (params[:mentor][:user_ids])+@mentor.user_ids)
      @mentor.send_notification_emails(params[:mentor][:user_ids])
      
      flash[:notice] = "Mentor's User associations successfully updated"
    else
      flash[:notice] = "Mentor's User associations could not be updated"
    end
    return redirect_to edit_mentor_path @mentor
  end
  
end
