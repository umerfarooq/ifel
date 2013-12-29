class PartnersController < ApplicationController
  uses_tiny_mce :only => [:list,:new,:create,:edit,:update]
  before_filter :redirect_nyu_user
  before_filter { |c| c.active_tab=:partners }
  before_filter :set_new_design_theme, :only => [:show, :index]
  before_filter :get_main_title_and_subtitle, :only => [:list,:index]
  before_filter :load_partners

  def index 
    @partner_request = PartnerRequest.new
  end

  def new
    @partner = Partner.new
  end

  def create
    @partner = Partner.new params[:partner]
    @partner.join_detail_page_titles(@partner.first_show_title, @partner.second_show_title)
    if @partner.save
      flash[:success] = "Partner successfully added."
      return redirect_to :list_partners
    else
      @partner.split_detail_page_title unless @partner.show_title.blank?
      render :action => :new
    end
  end

  def edit
    @partner = Partner.find params[:id]
    @partner.split_detail_page_title
  end

  def update
    @partner = Partner.find params[:id]
    @partner.join_detail_page_titles(params[:partner][:first_show_title], params[:partner][:second_show_title])
    if @partner.update_attributes(params[:partner])
      flash[:success] = "Partner successfully updated."
      return redirect_to :list_partners
    else
      @partner.split_detail_page_title unless @partner.show_title.blank?
      render :action => :edit
    end    
  end
  
  def show
    @partner = Partner.find params[:id]
  end

  def list
    @partners = Partner.all
  end

  def become_partner_request
    return render :text => {:success => true}.to_json
    @partner_request = PartnerRequest.new({:company_name=>params[:company_name], :contact_name => params[:contact_name], :phone_number => params[:phone_number], :email => params[:email]})
    if @partner_request.save
      @partner_request.send_later(:deliver_partner_request_email)
      return render :text => {:success => true}.to_json
    end
    return render :text => {:success => false}.to_json
  end

  def publish
    partner = Partner.find params[:id]
    if partner.publish
      flash[:notice] = "Partner successfully published"
    else
      flash[:notice] = "Partner is not publishable"
    end
    return redirect_to :back
  end

  def activate
    partner = Partner.find params[:id]
    if partner.activate
      flash[:notice] = "Partner successfully activated"
    else
      flash[:notice] = "Partner is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    partner = Partner.find params[:id]
    if partner.inactivate
      flash[:notice] = "Partner successfully inactivated"
    else
      flash[:notice] = "Partner is not inactivatable"
    end
    return redirect_to :back
  end
  
  private
  def get_main_title_and_subtitle
    @main_title = MarketingTextMessage.find_by_page_and_location('partner_page','main_title')
  end
  def load_partners
    @partners = Partner.published.date_wise
  end
  ################################################################################################
  # Commented out the previous Code stuff from this Module, to replace with the New Functionality#
  ################################################################################################

#  def index
#    @message_how  = MarketingTextMessage.find_by_page_and_location("how_lauch_pad_works", "how_lauch_pad_works")
#    @message_cost = MarketingTextMessage.find_by_page_and_location("how_lauch_pad_works", "cost_of_lauch_pad")
#    @partners_message = MarketingTextMessage.find(:all,:conditions=>{:title=>"OUR PARTNERS",:state_id => 1})
#    @partners = Partner.all
#  end
#
#  def new
#    @partner = Partner.new
#  end
#
#  def create
#    @partner = Partner.new(params[:partner])
#    if @partner.save
#      flash[:notice] = "Partner successfully added."
#      redirect_to '/admins/partners_tab'
#    else
#      render :action => 'new'
#    end
#  end
#
#  def edit
#    @partner = Partner.find_by_id(params[:id])
#  end
#
#  def update
#    @partner = Partner.find_by_id(params[:id])
#    if @partner.update_attributes(params[:partner])
#      flash[:notice] = "Partner updated successfully."
#      redirect_to '/admins/partners_tab'
#    else
#      render :action => 'edit'
#    end
#  end
#
#  def destroy
#    @faq = Faq.find_by_id(params[:id])
#    # @biography.destroy
#    @faq.status = "destroyed"
#    if @faq.save
#      flash[:notice] = 'Faq marked destroyed.'
#    else
#      flash[:notice] = 'Faq cannot be marked destroyed.'
#    end
#    redirect_to(root_path)
#  end
#
#  def change_state
#    @partner = Partner.find_by_id(params[:id])
#    @partner.state = State.find_by_title(params[:state])
#    if @partner.save
#      #redirect to the caller page
#    else
#
#    end
#    redirect_to '/admins/partners_tab'
#  end
#
end
