class ContactUs < ActiveRecord::Base

#  before_create :set_creation_defaults

  attr_accessible       :first_name, :last_name, :email, :subject_id, :message
  attr_reader :request_from
  validates_presence_of :first_name, :last_name, :email, :subject_id, :message

  validates_length_of   :first_name, :last_name,    :in => 2..250
#  validates_length_of   :subject, :in => 2..250
  validates_length_of   :message, :in => 2..65000
  validates_format_of   :email,   :with => Authlogic::Regex.email, :message => 'appears to be invalid'

  belongs_to :subject,:foreign_key => :subject_id

#  def set_creation_defaults
#    self.request_from ||= "contact_us"
#  end

  def deliver_contact_us_email
    AdminMailer.deliver_contact_us_email(self)
  end
  def deliver_newsletter_subscription_email
    AdminMailer.deliver_newsletter_subscription_email(self)
  end
end


class Contact < ContactUs
  
end

class Newsletter < ContactUs
  
end
