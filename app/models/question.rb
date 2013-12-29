class Question < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :state
  has_many :answers

  before_create :set_creation_defaults

  named_scope :published, :conditions => { :state_id => State.published.id }
  named_scope :sequence_wise, :order => 'sequence_number ASC'

  attr_accessible :statement, :comment, :response_no, :points_yes, :points_no, :points_sometimes

#  validates :quiz_association
  validates_presence_of :statement

  def set_creation_defaults
    if self.quiz.questions.blank?
      self.sequence_number = 1
    else
      self.sequence_number = self.quiz.questions.maximum('sequence_number') + 1
    end
    self.points_yes, self.points_no, self.points_sometimes = 1, 0, 0 unless self.point_based?
    self.state = State.inactivated
  end

  def point_based?
    self.quiz.point_based?
  end

  def points_for(reply)
    case reply.downcase
    when "yes"
      self.points_yes
    when "no"
      self.points_no
    else
      self.points_sometimes
    end
  end

  def published?
    self.state.is_published?
  end

  def activated?
    self.state.is_activated?
  end

  def inactivated?
    self.state.is_inactivated?
  end

  def publish
    if self.state.is_activated?
      self.state = State.published
      return self.save
    else
      return false
    end
  end

  def activate
    if self.state.is_inactivated?
      self.state = State.activated
      return self.save
    else
      return false
    end
  end

  def inactivate
    if self.state.is_inactivated?
      return false
    else
      self.state = State.inactivated
      return self.save
    end
  end

  def on_top?
    self.sequence_number == self.quiz.questions.minimum(:sequence_number)
  end

  def on_bottom?
    self.sequence_number == self.quiz.questions.maximum(:sequence_number)
  end

  def move_up
    if self.sequence_number > self.quiz.questions.minimum(:sequence_number)
      one_up_sno = self.quiz.questions.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      question_swap = self.quiz.questions.find_by_sequence_number(one_up_sno)
      question_swap.sequence_number = self.sequence_number
      self.sequence_number = one_up_sno
      self.save
      question_swap.save
      return true
    else
      return false
    end
  end

  def move_down
    if self.sequence_number < self.quiz.questions.maximum(:sequence_number)
      one_down_sno = self.quiz.questions.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      question_swap = self.quiz.questions.find_by_sequence_number(one_down_sno)
      question_swap.sequence_number = self.sequence_number
      self.sequence_number = one_down_sno
      self.save
      question_swap.save
      return true
    else
      return false
    end
  end

end
