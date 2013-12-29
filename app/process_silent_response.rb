class ProcessSilentResponse < ActiveRecord::Base
  ######################## Payment received successfully #############################
  #  silent_posts = SilentPost.find(:all,:conditions=>["created_at > ? AND created_at < ?", Date.yesterday, Date.today])
  #  puts "#{silent_posts.size} : is the size of silent posts"
  #  silent_posts.each do |slnt_pst|
  #    if slnt_pst.response_code == 1.to_s && slnt_pst.response_reason_code == 1.to_s
  #      puts "m in"
  #      user_credential = Credential.find_by_transaction_id(slnt_pst.subscription_id)
  #      unless user_credential.blank?
  #        puts "#{user_credential.user.email} is to be emailed!"
  #        user_credential.billing_date = Date.yesterday + 1.month
  #        user_credential.amount = RECURRING_AMOUNT
  #        user_credential.save
  #        #TODO send billing email
  #        unless slnt_pst.amount.blank?
  #          user_credential.user.deliver_charge_successful_email
  #        else
  #          user_credential.user.deliver_billing_email
  #        end
  #
  ##        @transaction_log = TransactionLog.new(:user_id => user_credential.user.id, :email => user_credential.user.email,  :activity => 'automated_recurring_billing', :activity_date => Date.today, :package_name => 'standard',:subscription_start_date => user_credential.billing_date, :is_wickedstart => true , :transaction_id => slnt_pst.subscription_id, :transaction_status => 'success', :amount => RECURRING_AMOUNT)
  ##        @transaction_log.save
  #
  #      end
  #    end
  #  end

  ######################## Payment not received after 3 days #############################
  users_credentials = Credential.find(:all,:conditions=>["billing_date = ?", (Date.today - 3.day)])
  puts "#{users_credentials.size} : is the size of warning people"
  users_credentials.each do |usr_crdntls|
    #TODO send email to change credit card
    puts "#{usr_crdntls.user.email} is to be emailed for warning!"
    usr_crdntls.user.deliver_warning_email
    apiresp = Credential.cancel_subscription(usr_crdntls.transaction_id)
    logger.info 'cancelling subscription'
    logger.info apiresp.messages
    if apiresp.success
      #TODO delete credentials
      @transaction_log = TransactionLog.new(:user_id => usr_crdntls.user.id, :email => usr_crdntls.user.email,  :activity => 'cancellation', :activity_date => Date.today, :subscription_end_date => Date.today,:package_name => usr_crdntls.user.promo_code.code, :is_wickedstart => true , :transaction_id => usr_crdntls.transaction_id, :transaction_status => 'success', :amount => 0)
      @transaction_log.save
      usr_crdntls.user.is_blocked = true
      usr_crdntls.user.save
      usr_crdntls.destroy
      logger.info 'subscription cancelled successful'
    else
      logger.info 'subscription cancelled failed'
    end
  end
    
  ######################## Payment not received after 7 days #############################
  users_credentials = Credential.find(:all,:conditions=>["billing_date = ?", (Date.today - 7.day)])
  puts "#{users_credentials.size} : is the size of blocking people"
  users_credentials.each do |usr_crdntls|
    #TODO send email for blocking account
    puts "#{usr_crdntls.user.email} is to be emailed for blocking!"
    usr_crdntls.user.deliver_block_account_email
    #TODO cancel subscription
    apiresp = Credential.cancel_subscription(usr_crdntls.transaction_id)
    logger.info 'cancelling subscription'
    logger.info apiresp.messages
    if apiresp.success
      #TODO delete credentials
      @transaction_log = TransactionLog.new(:user_id => usr_crdntls.user.id, :email => usr_crdntls.user.email,  :activity => 'cancellation', :activity_date => Date.today, :subscription_end_date => Date.today,:package_name => usr_crdntls.user.promo_code.code, :is_wickedstart => true , :transaction_id => usr_crdntls.transaction_id, :transaction_status => 'success', :amount => 0)
      @transaction_log.save
      usr_crdntls.user.is_blocked = true
      usr_crdntls.user.save
      usr_crdntls.destroy
      logger.info 'subscription cancelled successful'
    else
      logger.info 'subscription cancelled failed'
    end
    
  end

  ######################## Blocking a user on the specified date #############################
  users = User.find(:all,:conditions=>["expire_date = ? AND is_blocked !=?", Date.yesterday, 1])
  puts "#{users.size} : is the size of leaving people"
  users.each do |usr|
    #TODO delete credentials
    usr.is_blocked = true
    usr.save
    usr.credential.destroy
    logger.info 'subscription cancelled successful'
  end

end