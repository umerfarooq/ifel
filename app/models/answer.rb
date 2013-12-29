class Answer < ActiveRecord::Base
  belongs_to  :question
  belongs_to  :quiz_reply

  before_create :set_creation_defaults

  named_scope :right, :conditions => { :statement => "yes" }
  named_scope :wrong, :conditions => [ "statement <> ?", "yes" ]

  def set_creation_defaults
    self.score = self.question.points_for(self.statement)
  end

end
