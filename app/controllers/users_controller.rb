#require 'active_merchant'
#require 'ArbApiLib'
class UsersController < ApplicationController
  uses_tiny_mce :only => [:index,:edit,:update]
  ssl_required  :new, :create, :edit, :update
  ssl_allowed   :index, :destroy, :upload_picture, :guidance

  before_filter :require_admin, :only => [:index, :destroy]
  before_filter :require_user,  :only => [:edit, :update]
  before_filter :require_payment,  :only => [:edit, :update]
  before_filter :require_no_user,  :only => [:new, :create]
  before_filter :load_profile_contents,  :only => [:index, :edit, :update]
  #  before_filter { |c| c.active_tab=nil }
  before_filter { |c| c.active_tab=:content_tab }
  before_filter(:only => [:edit, :update]) { |c| c.active_tab=:startup_workspace }
  before_filter :set_new_design_theme, :only => [:new,:create, :edit, :update,:guidance]

  def index
    @users = User.all
    @section_templates = SectionTemplate.published.sequence_wise
    @registration_codes = RegistrationCode.all
  end

  def update_profile_summary
    marketing_text_message = MarketingTextMessage.find params[:id]
    if marketing_text_message.update_attributes(params[:marketing_text_message])
      flash[:notice] = "Profile Summary updated successfully."
    end
    redirect_to params[:back] || :back
  end

  def update_tooltip
    marketing_text_message = MarketingTextMessage.find params[:id]
    if marketing_text_message.update_attributes(params[:marketing_text_message])
      flash[:notice] = "Tooltip updated successfully."
    end
    redirect_to params[:back] || :back
  end

  def new
    @user = User.new
    @credential = @user.build_credential
    # Set this attribute, explicitly to observe, where Newsletter Subscription request is coming from (Signup is running on HTTPS so can't save HTTP REFERR session element)
    @page = 'signup'
  end

  def create    
    is_registered_successful = true
    #session[:promo_code_id] = nil
    #session[:promo_code] = nil
    @user = User.new(params[:user])
    @credential = @user.build_credential(params[:user][:credential]) #unless $is_ws_free_as_default
    @promotion_code = (params[:promotion][:code] unless params[:promotion][:code].blank?) unless $is_ws_free_as_default
    #    @user.login = params[:user][:login]
    #    @user.first_name = params[:user][:first_name]
    #    @user.last_name = params[:user][:last_name]
    #    @user.email = params[:user][:email]
    #    @user.terms_of_service = params[:user][:terms_of_service]
    #    @user.user_type_id = UserType.get_registered_type
    #    @user.industry_id = params[:user][:industry_id]
    #    @user.business_name = params[:user][:business_name]
    #    @user.screen_name = params[:user][:screen_name]
    #
    #    @user.build_credential(params[:user][:credential])
    #    #
    #    # Storing up Credentials, information to retain them on Post Back...
    #    #
    #    @exp_date = Date.new(params[:user][:credential]['card_expires_on(1i)'].to_i, params[:user][:credential]['card_expires_on(2i)'].to_i, params[:user][:credential]['card_expires_on(3i)'].to_i)
    #    @card_number = params[:user][:credential][:card_number]
    #    @card_verification = params[:user][:credential][:card_verification]
    #    @card_type = params[:user][:credential][:card_type]
    #    session[:promo_code] = params[:promotion][:code]


    #    if verify_recaptcha(:model => @user, :message => 'Wrong captcha, please re-enter.') && @user.valid?
    if @user.valid?
      unless $is_ws_free_as_default
        # Application level Transaction Log
        #      amount = 0
        #      @cdt_charge_log = CreditLog.new(:first_name => @user.first_name, :last_name => @user.last_name, :cdt_card_number => "not yet entered", :email => @user.email, :amount => amount, :step => @step, :ip_address => request.remote_ip)
        #      @cdt_charge_log.save

        # Active Merchant Credit Car Building
        credit_card = ActiveMerchant::Billing::CreditCard.new(
          :first_name         => @user.first_name,
          :last_name          => @user.last_name,
          :number             => @user.credential.card_number,
          :month              => @user.credential.card_expires_on.month,
          :year               => @user.credential.card_expires_on.year,
          :verification_value => @user.credential.card_verification
        )

        if credit_card.valid?
          # Promo Code Validation
          unless params[:promotion][:code].blank?
            @promo_code = PromoCode.find_by_code(params[:promotion][:code])
            if @promo_code.blank? || !@promo_code.status
              @error = :invalid_promo_code
              return render :action => 'new'
            end
            if !@promo_code.expire_date.nil?
              if Date.today >= @promo_code.expire_date
                @error = :invalid_promo_code
                return render :action => 'new'
              end
            end
            if @promo_code.register_limit != 0
              if @promo_code.register_counter >= @promo_code.register_limit
                @error = :invalid_promo_code
                return render :action => 'new'
              end
            end
          else
            @promo_code = PromoCode.find_by_code(DEFAULT_PACKAGE)
          end
          #session[:promo_code_id] = @promo_code.id

          # Process authorize.net Transaction, If Premium Promo Code Selected
          if @promo_code.registration_fee != 0 || @promo_code.recurring_fee != 0
            aReq = ArbApi.new
            auth = MerchantAuthenticationType.new(AUTHORIZE_NET_ID, AUTHORIZE_NET_KEY)
            subname = @user.email
            interval = IntervalType.new(1, "months")
            if @promo_code.registration_fee == 0
              schedule = PaymentScheduleType.new(interval, Date.today+@promo_code.month_begins.month+@promo_code.day_begins.day, OCCURRENCES, 0)
            else
              schedule = PaymentScheduleType.new(interval, Date.today+@promo_code.month_begins.month+@promo_code.day_begins.day, OCCURRENCES, TRIAL_OCCURRENCES)
            end
            cinfo = CreditCardType.new(credit_card.number, @user.credential.card_expires_on.year.to_s+'-'+@user.credential.card_expires_on.month.to_s)
            binfo = NameAndAddressType.new(@user.first_name, @user.last_name)
            xmlout = aReq.CreateSubscription(auth, subname, schedule, @promo_code.recurring_fee, @promo_code.registration_fee, cinfo,binfo)
            puts "Creating Subscription Name: " + subname
            xmlresp = HttpTransport.TransmitRequest(xmlout, AUTHORIZE_NET_REQUEST_URL)
            apiresp = aReq.ProcessResponse(xmlresp)

            if apiresp.success
              puts "Subscription Created successfully"
              puts "Subscription id : "
              puts "********************************************"
              puts apiresp
              puts "********************************************"
            else
              puts "Subscription Creation Failed"
              @error = :subscription_failed
              @err_msg = apiresp.messages
              apiresp.messages.each { |message|
                puts "Error Code=" + message.code
                puts "Error Message = " + message.text
              }
              puts "********************************************"
              puts apiresp
              puts "********************************************"
              return render :action => 'new'
              logger.info "subscription unsuccessfully"
              logger.info apiresp.messages
            end
            @user.credential.billing_date = Date.today+@promo_code.month_begins.month+@promo_code.day_begins.day

            # Rotate Promo Code Register Counter & See If it expires
            #@promo_code.register_counter += 1
            @promo_code.increment(:register_counter,1)
            if @promo_code.register_limit !=0 && (@promo_code.register_counter >= @promo_code.register_limit)
              @promo_code.is_expired = true
            end
            @promo_code.save
            @user.credential.amount = (@promo_code.registration_fee == 0) ? @promo_code.recurring_fee : @user.credential.amount = @promo_code.registration_fee

            @user.credential.card_last_four_digits = credit_card.number[-4..-1]
            @user.credential.transaction_id = apiresp.subscriptionid
            @user.credential.card_number = 'we are not storing it :)'
            @user.credential.card_type = 'we are not storing it :)'
            @user.credential.card_verification = 'we are not storing it :)'
            @cdt_charge_log = CreditLog.new(:first_name => credit_card.first_name, :last_name => credit_card.last_name, :cdt_card_number => credit_card.number[-4..-1], :email => @user.email, :amount => @promo_code.registration_fee, :step => @step, :ip_address => request.remote_ip)
            @cdt_charge_log.save
          else
            @promo_code.increment(:register_counter, 1)
            @promo_code.save

            @user.credential.billing_date = Date.today + 1000.year
            @user.credential.amount = @promo_code.recurring_fee
            @user.credential.card_last_four_digits = '0000'
            @user.credential.transaction_id = 'free_account'
            @user.credential.card_number = 'we are not storing it :)'
            @user.credential.card_type = 'we are not storing it :)'
            @user.credential.card_verification = 'we are not storing it :)'
            @cdt_charge_log = CreditLog.new(:first_name => @user.first_name, :last_name => @user.last_name, :cdt_card_number => '0000', :email => @user.email, :amount => @promo_code.registration_fee, :step => @step, :ip_address => request.remote_ip)
            @cdt_charge_log.save
          end
          #        @user.promo_code_id = session[:promo_code_id]
          @user.promo_code_id = @promo_code.id
          if @user.save
            @transaction_log = TransactionLog.new(:user_id => @user.id, :email => @user.email,  :activity => 'registration', :activity_date => Date.today, :package_name => @user.promo_code.code, :subscription_start_date => @user.credential.billing_date, :is_wickedstart => true , :transaction_id => @user.credential.transaction_id, :transaction_status => 'success', :amount => 0)
            @transaction_log.save
            #        session[:promo_code_id] = nil
            #        session[:promo_code] = nil
            @step = "confirmation"
            @user.deliver_confirmation_email
          else
            is_registered_successful = false
          end
        else
          @error = :invalid_card
          is_registered_successful = false
        end
      else
        promo_code = PromoCode.find_by_code(DEFAULT_PACKAGE)
        @user.credential.billing_date = (Date.today+1000.years)
        @user.credential.amount = promo_code.recurring_fee
        @user.credential.card_last_four_digits = '0000'
        @user.credential.transaction_id = 'free_account'
        @user.credential.card_number = 'we are not storing it :)'
        @user.credential.card_type = 'we are not storing it :)'
        @user.credential.card_verification = 'we are not storing it :)'
        cdt_charge_log = CreditLog.new(:first_name => @user.first_name, :last_name => @user.last_name, :cdt_card_number => '0000', :email => @user.email, :amount => promo_code.registration_fee, :step => 'confirmation', :ip_address => request.remote_ip)
        cdt_charge_log.save
        @user.promo_code_id = promo_code.id
        if @user.save
          promo_code.increment(:register_counter, 1)
          promo_code.save

          transaction_log = TransactionLog.new(:user_id => @user.id, :email => @user.email,  :activity => 'registration', :activity_date => Date.today, :package_name => promo_code.code, :subscription_start_date => @user.credential.billing_date, :is_wickedstart => true , :transaction_id => @user.credential.transaction_id, :transaction_status => 'success', :amount => 0)
          transaction_log.save
          
          #          set_shared_cookie(@user) 

          @user.deliver_confirmation_email
        else
          is_registered_successful = false
        end
      end
    else
      is_registered_successful = false
    end
    if is_registered_successful
      redirect_to root_url
    else
      return render :action => 'new'
    end
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user
    if params[:user].has_key?("old_password")
      (params[:user][:old_password].blank?)? (@user.old_password="1"):(@user.old_password=params[:user][:old_password])
      unless @user.varify_old_password
        @user.old_password="" if @user.old_password=="1"
        return render :action => 'edit'
      end
    end
    if @user.update_attributes(params[:user])     
      unless params[:user][:password].blank?
        forum_user = ForumAccount.find_by_username(@user.login)
        if forum_user
          forum_user.encrypt_and_save_new_password(params[:user][:password])
        end
      end
      
      flash[:notice] = "Successfully updated profile."
      redirect_to :action => 'edit'
    else
      @user.old_password="" if @user.old_password=="1"
      render :action => 'edit'
    end
  end
  
  def show
    @user = User.find params[:id]
  end

  def upload_picture
    user = User.find(params[:id].to_i)
    if user.update_attribute(:profile_picture, params[:userfile])
      return render :text => {:success => true, :path => user.profile_picture.url.as_json}.to_json
    else
      return render :text => {:success => false, :message => "File Not Saved", :errors => user.errors.as_json}.to_json
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])
    @user.status = "destroyed"
    if @user.save
      flash[:notice] = 'User marked destroyed.'
    else
      flash[:notice] = 'User cannot be marked destroyed.'
    end
    redirect_to(root_path)
  end

  def roles
    @users = User.all
    @section_templates = SectionTemplate.published.sequence_wise  
  end
  
  def login_available
    #  def chk_login_availability
    #    return render :text => params.inspect
    user = User.find_by_login(params[:login])
    #    if user == nil
    if user
      return render :text => 'not available'
    else
      return render :text => 'available'
    end
  end

  def guidance
    render :layout => false
  end

  def search
    users = User.search(params)
    section_templates = SectionTemplate.published.sequence_wise
    return render :partial => 'roles_panel', :locals=>{:users => users, :sections => section_templates}
  end

  def mark_as_employee
    user = User.find(params[:id].to_i)
    can_mark = (params[:mark_as_employee].to_s == 'true') ? true : false
    if user.mark_as_employee can_mark
      return render :text => {:success => true, :screen_name => user.name.to_s}.to_json
    else
      return render :text => {:success => false, :screen_name => user.name.to_s}.to_json
    end
  end

  def unmark_as_expert
    user = User.find(params[:id].to_i)

    if user.unmark_as_expert
      flash[:notice] = "#{user.name.to_s} is no more a Community Expert"
      return render :text => {:success => true, :screen_name => user.name.to_s}.to_json
    else
      flash[:notice] = "Changes can't be saved due to Internal System error, Pleaase try again"
      return render :text => {:success => false, :screen_name => user.name.to_s}.to_json
    end
  end
  
  #  def assign_mentor
  #    user = User.find(params[:id].to_i)
  #    mentor = Mentor.find(params[:mentor_id].to_i)
  #    if mentor
  #      if user.update_attribute(:mentor_id, mentor.id)
  #        mentor.notify_mentor_assignment(user)
  #        user.notify_mentor_assignment(mentor)
  #      
  #        return render :text => {:success => true, :screen_name => user.name.to_s, :mentor_name => mentor.name.to_s}.to_json
  #      else
  #        return render :text => {:success => false, :screen_name => user.name.to_s, :mentor_name => mentor.name.to_s}.to_json
  #      end
  #    else
  #      return render :text => {:success => false, :screen_name => user.name.to_s}.to_json
  #    end
  #  end
  
  def block_or_unblock
    user = User.find(params[:id])
    if params[:blocked] == '1'
      is_blocked = true
      expiry_date = Date.today
    else
      is_blocked = false
      expiry_date = nil
    end
    if user.update_attributes({:is_blocked => is_blocked, :expire_date => expiry_date})
      return render :text => {:success => true, :screen_name => user.name.to_s}.to_json
    else
      return render :text => {:success => false, :screen_name => user.name.to_s}.to_json
    end    
  end

  def community_answers
    user = User.find(params[:id].to_i)
    comments = user.comments.for_message
    return render :partial => "/messages/community_expert_answers", :locals => { :comments => comments}
  end
  
  #  def email_mentor
  #    user = User.find params[:id].to_i
  #    if user.email_mentor({:to => params[:to], :subject => params[:subject], :body => params[:body]})
  #      return render :text => {:success => true}.to_json
  #    end
  #    return render :text => {:success => false}.to_json
  #  end
  
  def dissociate_mentor
    user = User.find params[:id].to_i
    if user.update_attribute(:mentor_id, nil)
      flash[:notice] = "User has been dissociated successfully"
    else
      flash[:notice] = "User can't be dissociated"
    end
    return redirect_to :back
  end
  
  def update_experted_sections
    user = User.find(params[:id].to_i)
    
    if params[:user][:experted_sections]
      if user.update_attributes({ :is_community_expert => true, :experted_sections => params[:user][:experted_sections]})
        flash[:notice] = "#{user.name.to_s} has been marked as Community Expert"
      else
        flash[:notice] = "#{user.name.to_s} can't be marked as Community Expert"
      end
    else
      flash[:notice] = "Select any section(s) to mark user as Community Expert"
    end
    
    return redirect_to roles_users_path

  end

  private
  def load_profile_contents
    @profile_contents = MarketingTextMessage.get_profile_contents
  end
end