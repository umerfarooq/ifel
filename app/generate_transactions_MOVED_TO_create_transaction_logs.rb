class GenerateTransactions < ActiveRecord::Base
  User.all.each do |user|
    unless user.credential.blank?
      @transaction_log = TransactionLog.new(:user_id => user.id, :email => user.email,  :activity => 'registration', :activity_date => user.created_at, :package_name => user.promo_code.code, :subscription_start_date => user.created_at.to_date + user.promo_code.month_begins.month + user.promo_code.day_begins.day, :is_wickedstart => true , :transaction_id => user.credential.transaction_id, :transaction_status => 'success', :amount => 0, :created_at => user.created_at)
      @transaction_log.save
    end
  end

  SilentPost.all.each do |slnt_pst|
    if slnt_pst.response_code == 1.to_s && slnt_pst.response_reason_code == 1.to_s
      user_credential = Credential.find_by_transaction_id(slnt_pst.subscription_id)
      unless user_credential.blank?
        unless user_credential.user.blank?
          if slnt_pst.amount.to_f == user_credential.user.promo_code.registration_fee
            @transaction_log = TransactionLog.new(:user_id => user_credential.user.id, :email => user_credential.user.email,  :activity => 'registration_fee', :activity_date => slnt_pst.created_at, :package_name => user_credential.user.promo_code.code, :is_wickedstart => true , :transaction_id => slnt_pst.subscription_id, :transaction_status => 'success', :amount => slnt_pst.amount, :created_at => slnt_pst.created_at)
            @transaction_log.save
          else
            @transaction_log = TransactionLog.new(:user_id => user_credential.user.id, :email => user_credential.user.email,  :activity => 'automated_recurring_billing', :activity_date => slnt_pst.created_at, :package_name => user_credential.user.promo_code.code, :is_wickedstart => true , :transaction_id => slnt_pst.subscription_id, :transaction_status => 'success', :amount => slnt_pst.amount, :created_at => slnt_pst.created_at)
            @transaction_log.save
          end
        end
      end
    end
  end

  users = User.find_all_by_is_blocked(true)
  unless users.blank?
    users.each do |user|
      @transaction_log = TransactionLog.new(:user_id => user.id, :email => user.email,  :activity => 'cancellation', :activity_date => Date.today, :package_name => user.promo_code.code,:subscription_end_date => user.expire_date, :is_wickedstart => true , :transaction_status => 'success', :amount => 0, :created_at => user.expire_date)
      @transaction_log.save
    end
  end
  
end