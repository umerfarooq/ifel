class Biography < ActiveRecord::Base
#  sitemap
  belongs_to :state
  has_many :biography_links

  before_create :set_creation_defaults

  has_attached_file :photo, :styles => { :home_page => "112x112#", :team => "168x168#" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png"

  has_attached_file :video,
    :url => "/admin/:class/:attachment/:id/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:basename.:extension"

#  has_attached_file :video, {}.merge(PAPERCLIP_STORAGE_OPTIONS)

  
  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :founder, :conditions => {:is_founder => true}
  named_scope :team, :conditions => {:is_founder => false}
  named_scope :sequence_wise, :order => 'sequence_number ASC'
  named_scope :limit_biographies_index, :limit => 5

  attr_accessible         :name, :title, :description, :video, :photo, :photo_alt
#  attr_accessible         :name, :title, :birth_date, :description, :video, :photo, :has_video
  validates_presence_of   :name, :title, :description

  validates_length_of     :name,          :in => 2..250
  validates_length_of     :title,         :in => 2..250
  validates_length_of     :description,   :in => 2..65000

  validates_attachment_presence     :photo
  validates_attachment_size         :photo, :less_than => 10.megabytes, :if => Proc.new { |record| !record.photo_file_name.blank? }
  validates_attachment_content_type :photo, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.photo_file_name.blank? }

#  validates_attachment_presence     :video, :if => "has_video"
  validates_attachment_size         :video, :less_than => 100.megabytes, :if => Proc.new { |record| !record.video_file_name.blank? }
#  validates_attachment_content_type :video, :content_type => FILE_TYPE_VIDEO, :if => Proc.new { |record| !record.video_file_name.blank? }

  def set_creation_defaults
    if Biography.all.blank?
      self.sequence_number = 1
    else
      self.sequence_number = Biography.maximum('sequence_number') + 1
    end
    self.state = State.inactivated
  end

  def Biography.for_about_us_main
    Biography.published.sequence_wise.limit_biographies_index
  end
  def Biography.for_about_us_team
    Biography.published.sequence_wise
  end

  def founder?
    self.is_founder
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
    self.sequence_number == Biography.minimum(:sequence_number)
  end

  def on_bottom?
    self.sequence_number == Biography.maximum(:sequence_number)
  end

  def move_up
    if self.sequence_number > Biography.minimum(:sequence_number)
      one_up_sno = Biography.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      bio_swap = Biography.find_by_sequence_number(one_up_sno)
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
    if self.sequence_number < Biography.maximum(:sequence_number)
      one_down_sno = Biography.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      bio_swap = Biography.find_by_sequence_number(one_down_sno)
      bio_swap.sequence_number = self.sequence_number
      self.sequence_number = one_down_sno
      self.save
      bio_swap.save
      return true
    else
      return false
    end
  end

   # TODO [8/19/10 6:36 PM] => CHECK_IT
  def url_for_video_player
    if VIDEOS_ON_S3
      "http://wickedstartbucket.s3.amazonaws.com#{self.video.url(nil, false)}"
    else
      self.video.url(nil, false)
    end
  end

end
