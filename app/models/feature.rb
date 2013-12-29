class Feature < ActiveRecord::Base
  belongs_to :state
  acts_as_tree
  before_create :set_creation_defaults

  has_attached_file :video,
    :url => "/admin/:class/:attachment/:id/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:basename.:extension"

  has_attached_file :photo, :styles => { :small => "166x102!", :medium => "662x382!", :thumb => "42x31!"},
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension"

  validates_presence_of :photo

  #  validates_attachment_presence     :photo
  validates_attachment_size         :photo, :less_than => 10.megabytes, :if => Proc.new { |record| !record.photo_file_name.blank? }
  validates_attachment_content_type :photo, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.photo_file_name.blank? }

  #  validates_attachment_presence :multimedia
  validates_attachment_size         :video, :less_than => 100.megabytes, :if => Proc.new { |record| !record.video_file_name.blank? }

  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :get_parents, :conditions => {:parent_id => nil}
  named_scope :sequence_wise, :order => 'sequence_number ASC'
  named_scope :limit_features, :limit => 5


  attr_accessible         :name, :title, :description, :video, :photo, :sequence_number, :photo_alt

  def set_creation_defaults
    if Feature.all.blank?
      self.sequence_number = 1
    else
      if self.parent.blank?
        self.sequence_number = Feature.roots.last.sequence_number + 1
      else
        if self.parent.children.count == 0
          self.sequence_number = 1
        else
          self.sequence_number = self.parent.children.last.sequence_number + 1
        end
      end
    end
    self.state = State.inactivated
  end

  def Feature.for_index
    Feature.get_parents.published.sequence_wise.limit_features
  end
  #  def Feature.for_about_us_team
  #    Feature.published.sequence_wise
  #  end

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
    if self.parent_id.blank?
      self.sequence_number == Feature.minimum(:sequence_number)
    else
      self.sequence_number == self.parent.children.minimum(:sequence_number)
    end    
  end

  def on_bottom?
    if self.parent_id.blank?
      self.sequence_number == Feature.maximum(:sequence_number)
    else
      self.sequence_number == self.parent.children.maximum(:sequence_number)
    end
  end

  def move_up
    if self.parent.blank?
      if self.sequence_number > Feature.get_parents.minimum(:sequence_number)
        one_up_sno = Feature.maximum(:sequence_number, :conditions => ['parent_id is NULL AND sequence_number < ?', self.sequence_number])
        bio_swap = Feature.find_by_sequence_number_and_parent_id(one_up_sno, nil)
        bio_swap.sequence_number = self.sequence_number
        self.sequence_number = one_up_sno
        self.save
        bio_swap.save
        return true
      else
        return false
      end
    else
      if self.sequence_number > self.parent.children.minimum(:sequence_number)
        one_up_sno = Feature.maximum(:sequence_number, :conditions => ['parent_id = ? AND sequence_number < ?', self.parent_id ,self.sequence_number])
        bio_swap = Feature.find_by_sequence_number_and_parent_id(one_up_sno, self.parent_id)
        bio_swap.sequence_number = self.sequence_number
        self.sequence_number = one_up_sno
        self.save
        bio_swap.save
        return true
      else
        return false
      end
    end
  end

  def move_down
    if self.parent.blank?
      if self.sequence_number < Feature.get_parents.maximum(:sequence_number)
        one_up_sno = Feature.minimum(:sequence_number, :conditions => ['parent_id is NULL AND sequence_number > ?', self.sequence_number])
        bio_swap = Feature.find_by_sequence_number_and_parent_id(one_up_sno, nil)
        bio_swap.sequence_number = self.sequence_number
        self.sequence_number = one_up_sno
        self.save
        bio_swap.save
        return true
      else
        return false
      end
    else
      if self.sequence_number < self.parent.children.maximum(:sequence_number)
        one_up_sno = Feature.minimum(:sequence_number, :conditions => ['parent_id = ? AND sequence_number > ?', self.parent_id ,self.sequence_number])
        bio_swap = Feature.find_by_sequence_number_and_parent_id(one_up_sno, self.parent_id)
        bio_swap.sequence_number = self.sequence_number
        self.sequence_number = one_up_sno
        self.save
        bio_swap.save
        return true
      else
        return false
      end
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