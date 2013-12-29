class Industry < ActiveRecord::Base
  belongs_to  :state
  has_many :users
  has_many :success_stories
  has_and_belongs_to_many :mentors
  
  validates_presence_of :title
  
  named_scope :published, :conditions => {:state_id => [State.published.id]}
  named_scope :title_wise, :order => 'title ASC'
  named_scope :state_wise, :order => 'state_id DESC'



  before_create :set_creation_defaults


  def set_creation_defaults
    self.state = State.inactivated
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
  
  def self.is_other_industry?(industry_id)
    Industry.find(industry_id).title == 'Other'
  end
end
