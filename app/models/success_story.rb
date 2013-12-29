class SuccessStory < ActiveRecord::Base
  belongs_to :state
  belongs_to :industry
  belongs_to :marketing_element

  before_create :set_creation_defaults
  before_save :make_valid_url

  named_scope :publically_available, :conditions => {:state_id => [State.featurified.id, State.published.id]}
  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :featured, :conditions => {:state_id => State.featurified.id}
  named_scope :sequence_wise, :order => 'sequence_number ASC'
  named_scope :limit_stories_index, :limit => 5
  named_scope :limit_logos_features, :limit => 3
  named_scope :random,:order => 'rand()'
  named_scope :logo_exists, :conditions => {:is_logo => true}

  has_attached_file :photo, :styles => { :home_page => "100x100", :list => "150x150", :single => "150x150" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png"

  has_attached_file :logo, :styles => { :small => "100x100", :medium => "150x150", :grey => "280x60!" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension",
#    :default_url => "/admin/:class/:attachment/missing_:style.png",
    :convert_options => { :grey => '-colorspace Gray -strip' }

  has_attached_file :banner, :styles => { :normal => "168x348!" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png"

  attr_accessible         :name, :title, :story_title, :quote, :before_quote, :after_quote, :summary, :company_name, :founded, :employee_count, :url, :logo, :photo, :photo_alt, :banner, :banner_alt
  validates_presence_of   :name, :title, :story_title, :quote, :before_quote, :after_quote, :summary, :company_name, :founded

#  validates_attachment_presence     :logo
  validates_attachment_size         :logo, :less_than => 10.megabytes, :if => Proc.new { |record| !record.logo_file_name.blank? }
  validates_attachment_content_type :logo, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.logo_file_name.blank? }
  validates_attachment_presence     :photo
  validates_attachment_size         :photo, :less_than => 10.megabytes, :if => Proc.new { |record| !record.photo_file_name.blank? }
  validates_attachment_content_type :photo, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.photo_file_name.blank? }
  validates_attachment_size         :banner, :less_than => 10.megabytes, :if => Proc.new { |record| !record.banner_file_name.blank? }
  validates_attachment_content_type :banner, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.banner_file_name.blank? }



  def SuccessStory.for_home_page
    (SuccessStory.published || SuccessStory.featured).rand
  end

  def set_creation_defaults
    if SuccessStory.all.blank?
      self.sequence_number = 1
    else
      self.sequence_number = SuccessStory.maximum('sequence_number') + 1
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

  def featurified?
    self.state.is_featurified?
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

  def featurify
    if self.state.is_published?
      self.state = State.featurified
      return self.save
    else
      return false
    end
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
    self.sequence_number == SuccessStory.minimum(:sequence_number)
  end

  def on_bottom?
    self.sequence_number == SuccessStory.maximum(:sequence_number)
  end

  def move_up
    if self.sequence_number > SuccessStory.minimum(:sequence_number)
      one_up_sno = SuccessStory.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      story_swap = SuccessStory.find_by_sequence_number(one_up_sno)
      story_swap.sequence_number = self.sequence_number
      self.sequence_number = one_up_sno
      self.save
      story_swap.save
      return true
    else
      return false
    end
  end

  def move_down
    if self.sequence_number < SuccessStory.maximum(:sequence_number)
      one_down_sno = SuccessStory.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      story_swap = SuccessStory.find_by_sequence_number(one_down_sno)
      story_swap.sequence_number = self.sequence_number
      self.sequence_number = one_down_sno
      self.save
      story_swap.save
      return true
    else
      return false
    end
  end

  def has_logo?
    self.is_logo == true
  end

end
