class SilentPostsController < ApplicationController
  protect_from_forgery :except => [:make]
  def make
    @silent_post = SilentPost.new
    @silent_post.test_request = params[:x_test_request]
    @silent_post.amount = params[:x_amount]
    @silent_post.trial_amount = params[:x_trial_amount]
    @silent_post.response_code = params[:x_response_code]
    @silent_post.response_reason_code = params[:x_response_reason_code]
    @silent_post.response_reason_text = params[:x_response_reason_text]
    @silent_post.subscription_id = params[:x_subscription_id]
    @silent_post.transaction_response = params.to_json
    @silent_post.save

    if @silent_post.response_code == 1.to_s && @silent_post.response_reason_code == 1.to_s
      user_credential = Credential.find_by_transaction_id(@silent_post.subscription_id)
      unless user_credential.blank?
        user_credential.billing_date = Date.today + 1.month
        user_credential.amount = user_credential.user.promo_code.recurring_fee
        user_credential.save
        (user_credential.user.amount_paid.nil?)?user_credential.user.amount_paid = @silent_post.amount.to_f : user_credential.user.amount_paid+=@silent_post.amount.to_f
        user_credential.user.save
        
        #TODO send billing email
        if @silent_post.amount.to_f == user_credential.user.promo_code.registration_fee
          user_credential.user.deliver_billing_email
          @transaction_log = TransactionLog.new(:user_id => user_credential.user.id, :email => user_credential.user.email,  :activity => 'registration_fee', :activity_date => Date.today, :package_name => user_credential.user.promo_code.code, :is_wickedstart => true , :transaction_id => @silent_post.subscription_id, :transaction_status => 'success', :amount => @silent_post.amount)
          @transaction_log.save
          return render :text => 'deliver billing email'
        else
          user_credential.user.deliver_charge_successful_email
          @transaction_log = TransactionLog.new(:user_id => user_credential.user.id, :email => user_credential.user.email,  :activity => 'automated_recurring_billing', :activity_date => Date.today, :package_name => user_credential.user.promo_code.code, :is_wickedstart => true , :transaction_id => @silent_post.subscription_id, :transaction_status => 'success', :amount => @silent_post.amount)
          @transaction_log.save
          return render :text => 'deliver charge email'
        end

      end
    end
    return  render :text => true
  end

  #  def create
  #    @silent_post = SilentPost.new
  #    @silent_post.transaction_response = params.to_json
  #    return render :text => @silent_post.transaction_response
  #    @silent_post.save
  #  end

end
