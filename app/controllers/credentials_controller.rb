class CredentialsController < ApplicationController
  require 'ArbApiLib'

  def new
    flash[:error] = "Please update your credit card information."
    @credential = Credential.new
  end

  def create
    #    return render :text => 'aa gya'
    @user = current_user
    @credential = Credential.new(params[:credential])

    credit_card = ActiveMerchant::Billing::CreditCard.new(
      :first_name         => @credential.first_name,
      :last_name          => @credential.last_name,
      :number             => params[:credential][:card_number],
      :month              => @credential.card_expires_on.month,
      :year               => @credential.card_expires_on.year,
      :verification_value => params[:credential][:card_verification]
    )
    
    unless @credential.valid?
      return render :action => 'new'
    end

    if credit_card.valid?
      gateway = ActiveMerchant::Billing::Base.gateway(:authorize_net).new(AUTHORIZE_NET_CREDENTIALS)
      ActiveMerchant::Billing::Base.mode = :live
      #      amount = 1
      # TODO # EXTERNAL SITE DEPENDENCY CHECK => SOCKET ERROR EXCEPTION
      # TODO the units for active merchant are cents not dollars. So we should authorize amount in cents.
      response = gateway.authorize((@user.promo_code.recurring_fee*100), credit_card)
      authorize_response = response
      if response.success?
        aReq = ArbApi.new
        auth = MerchantAuthenticationType.new(AUTHORIZE_NET_ID, AUTHORIZE_NET_KEY)
        subname = @user.email
        interval = IntervalType.new(1, "months")
        schedule = PaymentScheduleType.new(interval, Date.today+1.month,9999, 0)
        cinfo = CreditCardType.new(credit_card.number, @credential.card_expires_on.year.to_s+'-'+@credential.card_expires_on.month.to_s)
        binfo = NameAndAddressType.new(@credential.first_name, @credential.last_name)
        xmlout = aReq.CreateSubscription(auth,subname,schedule,@user.promo_code.recurring_fee, 0, cinfo,binfo)

        puts "Creating Subscription Name: " + subname
        xmlresp = HttpTransport.TransmitRequest(xmlout, AUTHORIZE_NET_REQUEST_URL)

        apiresp = aReq.ProcessResponse(xmlresp)

        if apiresp.success
          response = gateway.capture((@user.promo_code.recurring_fee * 100), response.authorization)
          if response.success?
            logger.info 'subscription created successfully'
          else
            gateway.void(authorize_response.authorization)
            xmlout = aReq.CancelSubscription(auth,apiresp.subscriptionid)
            xmlresp = HttpTransport.TransmitRequest(xmlout, AUTHORIZE_NET_REQUEST_URL)
            apiresp = aReq.ProcessResponse(xmlresp)
            logger.info 'cancelling subscription'
            logger.info apiresp.messages
            @step = "billing"
            @error = :subscription_cancelled
            return render :action => 'new'
          end
          puts "Subscription Created successfully"
          puts "Subscription id : "
          #              + apiresp.subscriptionid
          puts "********************************************"
          puts apiresp
          puts "********************************************"
        else
          gateway.void(authorize_response.authorization)
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
          @step = "billing"
          return render :action => 'new'
          logger.info "subscription unsuccessfully"
          logger.info apiresp.messages
        end

        @credential.amount = @user.promo_code.recurring_fee
        @credential.billing_date = Date.today + 1.month
        @credential.transaction_id = apiresp.subscriptionid
        @credential.card_number = 'we are not storing it :)'
        @credential.card_type = 'we are not storing it :)'
        @credential.card_verification = 'we are not storing it :)'
        @credential.card_last_four_digits = credit_card.number[-4..-1]
        @cdt_charge_log = CreditLog.new(:first_name => credit_card.first_name, :last_name => credit_card.last_name, :cdt_card_number => credit_card.number[-4..-1], :email => @user.email, :amount => @user.promo_code.recurring_fee, :step => @step, :ip_address => request.remote_ip)
        @cdt_charge_log.save

        #            @credential.save
        @user.is_blocked = false
        @user.reactivation_date = Date.today
        @user.save
        @credential.user = @user
        @credential.save
        @transaction_log = TransactionLog.new(:user_id => @user.id, :email => @user.email,  :activity => 'renewal', :activity_date => Date.today, :package_name => @user.promo_code.code, :subscription_start_date => @credential.billing_date, :is_wickedstart => true , :transaction_id => @credential.transaction_id, :transaction_status => 'success', :amount => @user.promo_code.recurring_fee)
        @transaction_log.save
        # TODO send email for charging
        return redirect_to root_url
      else
        @error = :insufficient_balance
        return render :action => 'new'
      end
    else
      @error = :invalid_card
      return render :action => 'new'
    end
  end

  def edit
    #  @user = User.find_by_id(params[:user_id])
    @user = current_user
    @credential = @user.credential
  end

  def update
    #    return render :text => params.inspect
    @user = current_user
    @credential = @user.credential
    @credential.update_attributes(params[:credential])

    credit_card = ActiveMerchant::Billing::CreditCard.new(
      :first_name         => @credential.first_name,
      :last_name          => @credential.last_name,
      :number             => params[:credential][:card_number],
      :month              => @credential.card_expires_on.month,
      :year               => @credential.card_expires_on.year,
      :verification_value => params[:credential][:card_verification]
    )

    if credit_card.valid?
      #    gateway = ActiveMerchant::Billing::Base.gateway(:authorize_net).new(AUTHORIZE_NET_CREDENTIALS)
      #    ActiveMerchant::Billing::Base.mode = :live
    
      # TODO # EXTERNAL SITE DEPENDENCY CHECK => SOCKET ERROR EXCEPTION
      # TODO the units for active merchant are cents not dollars. So we should authorize amount in cents.
      #    response = gateway.authorize(RECURRING_AMOUNT_CENTS, credit_card)
      #
      #    if response.success?

      #      unless gateway.void(response.authorization).success?
      #        logger.info "__ __CONTROLLER:CREDENTIALS__ __ACTION:UPDATE__ __"
      #        logger.info "__VOIDFAILED FROM ACTIVEMERCHANT__ "
      #        logger.info response.authorization
      #      end
      aReq = ArbApi.new
      auth = MerchantAuthenticationType.new(AUTHORIZE_NET_ID, AUTHORIZE_NET_KEY)
      subname = @user.email
      interval = IntervalType.new(1, "months")
      #            schedule = PaymentScheduleType.new(interval, Date.today,9999, 0)
      subId = @credential.transaction_id
      cinfo = CreditCardType.new(credit_card.number, @credential.card_expires_on.year.to_s+'-'+@credential.card_expires_on.month.to_s)
      xmlout = aReq.UpdateSubscription(auth,subId,@user.promo_code.recurring_fee, @user.promo_code.registration_fee, cinfo)

      xmlresp = HttpTransport.TransmitRequest(xmlout, AUTHORIZE_NET_REQUEST_URL)
      #            return render :xml => xmlresp
      apiresp = aReq.ProcessResponse(xmlresp)
      if apiresp.success
        puts "Subscription Created successfully"
      else
        puts "Subscription Creation Failed"
        @error = :update_subscription_failed
        @err_msg = apiresp.messages
        apiresp.messages.each { |message|
          puts "Error Code=" + message.code
          puts "Error Message = " + message.text
        }
        logger.info apiresp.messages
        return render :action => 'edit'
      end
            
      if apiresp.success
        @cdt_charge_log = CreditLog.new(:first_name => credit_card.first_name, :last_name => credit_card.last_name, :cdt_card_number => credit_card.number[-4..-1], :email => @user.email, :amount => @user.promo_code.recurring_fee, :step => @step, :ip_address => request.remote_ip)
        @cdt_charge_log.save
        @credential.card_last_four_digits = credit_card.number[-4..-1]
        @credential.card_number = 'we are not saving it :)'
        @credential.card_type = 'we are not saving it :)'
        @credential.card_verification = 'we are not saving it :)'
        @credential.save
        @error = :update_cdt_successful
        flash[:notice] = 'Credit Card Changed Successfully'
        redirect_to edit_user_path(current_user)
      else
        @error = :update_cdt_crd_fld
        return render :action => 'edit'
      end
      #    else
      #      @error = :insufficient_balance
      #      return render :action => 'edit'
      #    end
    else
      @error = :invalid_card
      return render :action => 'edit'
    end
  end

  def cancel_subscription  
    @user = current_user
    
    unless $is_ws_free_as_default
      apiresp = Credential.cancel_subscription(current_user.credential.transaction_id)
      logger.info 'cancelling subscription'
      logger.info apiresp.messages
      if apiresp.success
        @transaction_log = TransactionLog.new(:user_id => @user.id, :email => @user.email,  :activity => 'cancellation', :activity_date => Date.today, :package_name => @user.promo_code.code,:subscription_end_date => @user.credential.billing_date, :is_wickedstart => true , :transaction_id => @user.credential.transaction_id, :transaction_status => 'success', :amount => 0)
        @transaction_log.save
        #TODO send email
        @error = :subscription_cancelled
        logger.info 'subscription cancellaion successful'
        #    return render :action => 'edit'
        current_user.expire_date = current_user.credential.billing_date
        current_user.save
        current_user.deliver_leave_account_email
        flash[:notice] = 'Successfully unsubscribed'
        redirect_to edit_user_path(current_user, :success => 'true')
      else
        @error = :subscription_cancel_unsuccessful
        logger.info 'subscription cancellation failed'
        flash[:notice] = 'UnSubscription failed'
        redirect_to edit_user_path(current_user)
      end
    else
      transaction_log = TransactionLog.new(:user_id => @user.id, :email => @user.email,  :activity => 'cancellation', :activity_date => Date.today, :package_name => @user.promo_code.code,:subscription_end_date => Date.today, :is_wickedstart => true , :transaction_id => (@user.credential.transaction_id rescue 'unspecified'), :transaction_status => 'success', :amount => 0)
      transaction_log.save
      current_user.expire_date = Date.today
      current_user.is_blocked = 1
      current_user.save
      current_user.deliver_leave_account_email
      flash[:notice] = 'Successfully unsubscribed, thank you for using WIBO'
      user_session = UserSession.find
      user_session.destroy
      redirect_to public_home_url(:path => 'exit')
    end
  end
end
