class PartnerRequest < ActiveRecord::Base
  validates_presence_of :company_name, :contact_name, :phone_number, :email

  def deliver_partner_request_email
    AdminMailer.deliver_partner_request_email(self)
  end
end
