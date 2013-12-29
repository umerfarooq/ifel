class TestEmails < ActiveRecord::Base
  #  @user = User.find_by_email('Abdullah.Muhammad@confiz.com')
  #  @user = User.last
  #  @user.deliver_confirmation_email
  #  @user.deliver_billing_email
  #  @user.deliver_leave_account_email
  #  @user.deliver_charge_successful_email
  promo_code = PromoCode.find_by_code('standard_package')
  users = User.all
  users.each do |user|
    user.promo_code_id = promo_code.id
    user.save
  end
end