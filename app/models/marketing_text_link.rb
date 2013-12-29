class MarketingTextLink < ActiveRecord::Base
  belongs_to :marketing_text_message
  belongs_to :state
  named_scope :published, :conditions => {:state_id => State.published.id}
end
