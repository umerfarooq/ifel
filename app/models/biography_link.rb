class BiographyLink < ActiveRecord::Base
  belongs_to :biography
  belongs_to :biography_link_category
  belongs_to :state

  before_create :set_creation_defaults
  before_save :make_valid_url

  attr_accessible :text, :url
  #  :sequence_number

  named_scope :with_category, lambda { |category_id| { :conditions => {:biography_link_category_id => category_id} } }
  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :sequence_wise, :order => 'sequence_number ASC'

  def set_creation_defaults
    if self.biography.biography_links.with_category(self.biography_link_category).blank?
      self.sequence_number = 1
    else
      self.sequence_number = self.biography.biography_links.with_category(self.biography_link_category).maximum('sequence_number') + 1
    end
    self.state = State.inactivated
  end

  def make_valid_url
    unless self.url.blank?
      if !self.url.include?('http://') and !self.url.include?('https://')
        self.url = 'http://'.concat(self.url.to_s)
      end
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
    self.sequence_number == self.biography.biography_links.with_category(self.biography_link_category).minimum(:sequence_number)
  end

  def on_bottom?
    self.sequence_number == self.biography.biography_links.with_category(self.biography_link_category).maximum(:sequence_number)
  end

  def move_up
    if self.sequence_number > self.biography.biography_links.with_category(self.biography_link_category).minimum(:sequence_number)
      one_up_sno = self.biography.biography_links.with_category(self.biography_link_category).maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      bio_swap = self.biography.biography_links.with_category(self.biography_link_category).find_by_sequence_number(one_up_sno)
      bio_swap.sequence_number = self.sequence_number
      self.sequence_number = one_up_sno
      self.save
      bio_swap.save
      return true
    else
      return false
    end
  end

  def move_down
    if self.sequence_number < self.biography.biography_links.with_category(self.biography_link_category).maximum(:sequence_number)
      one_down_sno = self.biography.biography_links.with_category(self.biography_link_category).minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      bio_swap = BiographyLink.find_by_sequence_number(one_down_sno)
      bio_swap.sequence_number = self.sequence_number
      self.sequence_number = one_down_sno
      self.save
      bio_swap.save
      return true
    else
      return false
    end
  end

end
