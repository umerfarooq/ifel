class FaqCategory < ActiveRecord::Base
  belongs_to :state
  has_many :faqs, :dependent => :destroy

  attr_accessible       :name, :title, :description
  validates_presence_of :title

  named_scope :published, :conditions => {:state_id => State.published.id}

#  def active_faqs
#    afaqs
#    self.faqs.each do |faq|
#      afaqs << faq unless faq.status == "unactive"
#    end
#    afaqs
#  end
end
