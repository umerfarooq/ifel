class Faq < ActiveRecord::Base
  belongs_to :faq_category
  belongs_to :state

  attr_accessible       :name, :question, :answer, :is_public
  before_create :set_creation_defaults
  
  
  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :public, :conditions => {:is_public => true}

  validates_presence_of :question, :answer, :faq_category_id

#  validates_length_of     :name,      :in => 2..250
  validates_length_of     :question,  :maximum => 250
  validates_length_of     :answer,    :maximum => 65000

  private
  def set_creation_defaults
    self.state = State.inactivated
  end 
end
