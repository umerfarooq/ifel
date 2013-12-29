class EventCategory < ActiveRecord::Base
  belongs_to :state
  has_many :events, :dependent => :destroy

  attr_accessible :title#, :description
  #  :sequence_number
  
  validates_presence_of :title

  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :sequence_wise, :order => 'sequence_number ASC'
  named_scope :title_wise, :order => 'title ASC'

  before_create :set_creation_defaults

  def set_creation_defaults
    self.state = State.inactivated
    if EventCategory.all.blank?
      self.sequence_number = 1
    else
      self.sequence_number = EventCategory.maximum('sequence_number') + 1
    end
  end
  
  def EventCategory.public_categories
    EventCategory.published.title_wise
  end

  def public_events
    self.events.published.date_wise.active_events
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
  
  def creation_date
    self.created_at.strftime('%Y-%m-%d')
  end

  def is_of_events_category?
    self.title == 'Events'
  end

end
