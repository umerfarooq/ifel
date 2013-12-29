class MessageRating < ActiveRecord::Base
   # TODO [8/6/10 5:16 PM] => REMOVE CLASS
  belongs_to :user
  belongs_to :message
  attr_accessible :rate
#  after_save :update_message
#  def update_message
#    self.message.update_rating
#  end
end
