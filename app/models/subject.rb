class Subject < ActiveRecord::Base
  has_many :contact_us
  named_scope :newsletter_subjects, :conditions=>{:for => 'newsletter'}
  named_scope :contactus_subjects, :conditions=>{:for => 'contactus'}
end
