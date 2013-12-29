class SectionTemplatesTopic < ActiveRecord::Base
  belongs_to :section_template
  belongs_to :topic
  belongs_to :state

  named_scope :defaults, :conditions => {:is_default => true}
  named_scope :published, :conditions => {:state_id => State.published.id}

  def is_published?
    self.state == State.published
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
end
