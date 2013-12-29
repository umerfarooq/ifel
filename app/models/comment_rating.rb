class CommentRating < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment
  attr_accessible :is_positive
#  after_save :update_comment
#  def update_comment
#    self.comment.update_rating
#  end
end
