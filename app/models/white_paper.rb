class WhitePaper < ActiveRecord::Base
  #  belongs_to :news_provider
  belongs_to :state

  has_attached_file :paper,
    :url => "/:class/:id/:filename",
    :path => ":rails_root/assets/admin/:class/:attachment/:id/:basename.:extension"

  before_create :set_creation_defaults
  before_paper_post_process :image?

  named_scope :for_public, :conditions => {:is_internal => false}
  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :sequence_wise, :order => 'sequence_number DESC'
#  named_scope :limit_radar, :limit => ON_THE_RADAR_WHITE_PAPER_COUNT

  attr_accessible :title, :summary, :paper, :is_internal

  validates_presence_of :title, :paper

  validates_length_of :title,   :maximum => 250
  validates_length_of :summary, :maximum => 65000
  
  validates_attachment_presence     :paper
  validates_attachment_size         :paper, :less_than => 100.megabytes, :if => Proc.new { |record| !record.paper_file_name.blank? }
  validates_attachment_content_type :paper, :content_type => FILE_TYPE_PDF, :if => Proc.new { |record| !record.paper_file_name.blank? }, :message => "Only PDF documents can be uploaded."

  #  validate :must_belong_to_provider

  def image?
    !(paper_content_type =~ /^image.*/).nil?
  end

  def set_creation_defaults
    if WhitePaper.all.blank?
      self.sequence_number = 1
    else
      self.sequence_number = WhitePaper.maximum('sequence_number') + 1
    end
    self.state = State.inactivated
  end

  def description
    return summary
  end

  def internal?
    self.is_internal
  end

  def not_published?
    !(self.state.is_published? || self.state.is_featurified?)
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
    self.sequence_number == WhitePaper.maximum(:sequence_number)
  end

  def on_bottom?
    self.sequence_number == WhitePaper.minimum(:sequence_number)
  end

  def move_up
    if self.sequence_number < WhitePaper.maximum(:sequence_number)
      one_up_sno = WhitePaper.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      paper_swap = WhitePaper.find_by_sequence_number(one_up_sno)
      paper_swap.sequence_number = self.sequence_number
      self.sequence_number = one_up_sno
      self.save
      paper_swap.save
      return true
    else
      return false
    end
  end

  def move_down
    if self.sequence_number > WhitePaper.minimum(:sequence_number)
      one_down_sno = WhitePaper.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      paper_swap = WhitePaper.find_by_sequence_number(one_down_sno)
      paper_swap.sequence_number = self.sequence_number
      self.sequence_number = one_down_sno
      self.save
      paper_swap.save
      return true
    else
      return false
    end
  end

end
