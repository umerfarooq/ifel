class SectionTemplate < ActiveRecord::Base
  belongs_to :state
  has_many :item_templates, :dependent => :destroy
  has_many :sections, :dependent => :destroy
  has_many :messages, :dependent => :destroy
  has_one :common_question, :dependent => :destroy

  has_many :section_templates_topics, :dependent => :destroy
  has_many :topics, :through => :section_templates_topics
  has_one :resource_text_message,:as=>:resource

  has_attached_file :multimedia,
    :styles => { :normal => "250x250#", :small => ["100x100>", :jpg], :tiny1 => "25x25#" , :tiny2 => "35x35#" , :tiny3 => "50x50#" }, :default_style => :normal,
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension"

  has_attached_file :side_bar_image,
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension"
  
  has_attached_file :chart,
    :url => "/admin/:class/:attachment/:id/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:basename.:extension"
  

  named_scope :published, :conditions => {:state_id => State.find_by_name('publish').id}
  named_scope :sequence_wise, :order => 'section_templates.sequence_number ASC'
  named_scope :wibo, :conditions => {:associated_with => 'wibo'}
  named_scope :ifel, :conditions => {:associated_with => 'ifel'}

  before_create :set_creation_defaults
  before_multimedia_post_process :image?

  #  attr_accessible :name, :sequence_number, :title, :title_comment, :summary, :introduction, :item_count, :is_active, :is_multimedia_video, :multimedia_file_name
  attr_accessible :name, :title, :title_comment, :introduction, :side_bar_image, :is_multimedia_video, :multimedia, :due_days_30, :due_days_60, :due_days_120, :associated_with, :chart

  validates_presence_of :name, :title, :introduction, :due_days_30, :due_days_60, :due_days_120

  validates_attachment_presence :multimedia
  validates_attachment_size :multimedia, :less_than => 500.megabytes, :if => Proc.new { |record| !record.multimedia_file_name.blank? }, :message => "must be less than 100 megabytes"
  validates_attachment_presence :chart
  validates_attachment_size :chart, :less_than => MAXSIZE_USER_DOCUMENT, :if => Proc.new { |record| !record.chart_file_name.blank? }, :message => "must be less than 50 megabytes"
  validates_attachment_content_type :chart, :content_type => FILE_TYPE_CHART, :if => Proc.new { |record| !record.chart_file_name.blank? }
  
  # TODO WINDOWS MIME_TYPE_FILTER for FLV
  #  validates_attachment_content_type :multimedia, :content_type => FILE_TYPE_VIDEO, :if => "is_multimedia_video", :message => "must be flv-video"
  #  validates_attachment_content_type :multimedia, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| (!record.multimedia_file_name.blank?)&&(!record.is_multimedia_video) }, :message => "must be image"

  def belongs_to_ifel
    self.associated_with == 'ifel'
  end
  
  def default_topics
    self.section_templates_topics.defaults
  end

  def image?
    !(multimedia_content_type =~ /^image.*/).nil?
  end

  def set_creation_defaults  
    if self.associated_with == 'wibo'
      if SectionTemplate.wibo.blank?
        self.sequence_number = 1
      else
        self.sequence_number = SectionTemplate.wibo.maximum("sequence_number") + 1
      end    
    else
      if SectionTemplate.ifel.blank?
        self.sequence_number = 1
      else
        self.sequence_number = SectionTemplate.ifel.maximum("sequence_number") + 1
      end           
    end     
    self.state_id = (State.find_by_name("inactivate")).id
  end

  #  def SectionTemplate.all_active
  #    SectionTemplate.all
  #    # SectionTemplate.find_all_by_state_id((State.find_by_title("create")).id)
  #  end

  def name_with_title
    "#{self.name}: #{self.title}"
  end

  def on_top?
    if self.associated_with == 'wibo'
      s_no = SectionTemplate.wibo.minimum(:sequence_number)
    else
      s_no =  SectionTemplate.ifel.minimum(:sequence_number)
    end
    self.sequence_number == s_no
  end

  def on_bottom?
    if self.associated_with == 'wibo'
      s_no = SectionTemplate.wibo.maximum(:sequence_number)
    else
      s_no =  SectionTemplate.ifel.maximum(:sequence_number)
    end
    self.sequence_number == s_no
  end

  def move_up
    if self.associated_with == 'wibo'
      valid = self.sequence_number > SectionTemplate.wibo.minimum(:sequence_number)
      one_up_sno = SectionTemplate.wibo.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      st_swap = SectionTemplate.find_by_sequence_number_and_associated_with(one_up_sno, 'wibo')
    else
      valid = self.sequence_number > SectionTemplate.ifel.minimum(:sequence_number)     
      one_up_sno = SectionTemplate.ifel.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      st_swap = SectionTemplate.find_by_sequence_number_and_associated_with(one_up_sno, 'ifel')
    end
    if valid    
      st_swap.sequence_number = self.sequence_number
      st_swap.save_with_validation(false)
      self.sequence_number = one_up_sno
      self.save_with_validation(false)      
      return true
    else
      return false
    end
  end

  def move_down
    if self.associated_with == 'wibo'
      valid = self.sequence_number < SectionTemplate.wibo.maximum(:sequence_number)      
      one_down_sno = SectionTemplate.wibo.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      st_swap = SectionTemplate.find_by_sequence_number_and_associated_with(one_down_sno, 'wibo')
    else
      valid = self.sequence_number < SectionTemplate.ifel.maximum(:sequence_number)     
      one_down_sno = SectionTemplate.ifel.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      st_swap = SectionTemplate.find_by_sequence_number_and_associated_with(one_down_sno, 'ifel')
    end
    if valid
      
      st_swap.sequence_number = self.sequence_number
      st_swap.save_with_validation(false)
      self.sequence_number = one_down_sno
      self.save_with_validation(false)      
      return true
    else
      return false
    end
  end

  # TODO [8/19/10 6:36 PM] => CHECK_IT
  def url_for_video_player
    if VIDEOS_ON_S3
      "http://wickedstartbucket.s3.amazonaws.com#{self.multimedia.url(:original, false)}"
    else
      self.multimedia.url(:original, false)
    end
  end
  def self.resource_ids(section_template_id)
    item_template_ids = ItemTemplate.find(:all,:select=>'id',:conditions=>["section_template_id=?",section_template_id])
    resource_ids = Resourcification.find(:all,:select=>'resource_id as id',:conditions=>["item_template_id IN (?) AND resourcifications.state_id =?",item_template_ids,3],:group => 'resource_id',:order => 'resource_id ASC')
    return resource_ids
  end
  
  def synchronized
    is_sync = false    
    Project.find_in_batches do |projects|
      projects.each do |project|
        section = project.sections.find_by_section_template_id self.id        
        if section
          due_date = nil
          case project.max_days
          when 30
            due_date = project.start_date + self.due_days_30.to_i
          when 60
            due_date = project.start_date + self.due_days_60.to_i
          when 120
            due_date = project.start_date + self.due_days_120.to_i
          else
            due_date = nil
          end
          
          Rails.logger.info("--------------------------------Templates Sequence No = #{self.sequence_number.to_s}--------------------------")
          
          if section.update_attributes({:name => self.name, 
                :sequence_number => self.sequence_number,
                :title => self.title, 
                :title_comment => self.title_comment, 
                :introduction => self.introduction, 
                :due_date => due_date})
            is_sync = true
          end
        else
          next unless self.state.is_published?
          next if self.item_templates.published.blank?
          section = Section.new(
            :name => self.name,
            :sequence_number => self.sequence_number,
            :title => self.title,
            :title_comment => self.title_comment,
            :introduction => self.introduction
          )
          section.item_count = self.item_templates.published.count
          section.items_completed_count = 0
          section.do_show_intro = true
          case project.max_days
          when 30
            section.due_date = project.start_date + self.due_days_30.to_i
          when 60
            section.due_date = project.start_date + self.due_days_60.to_i
          when 120
            section.due_date = project.start_date + self.due_days_120.to_i
          else
            section.due_date = nil
          end
          section.section_template = self
          section.project = project
          if section.save
            self.item_templates.published.sequence_wise.each do |it|
              item = Item.new(
                :item_number => it.item_number,
                :sequence_number => it.sequence_number,
                :title => it.title,
                :definition => it.definition,
                :percent => it.percent,
                :has_textbox => it.has_textbox,
                :has_upload => it.has_upload
              )
              item.is_complete = false
              item.is_applicable = true
              item.item_template = it
              item.section = section
              item.save
            end 
            is_sync = true
          end       
        end
      end        
    end
    is_sync    
  end
  
  
  #  def self.resources(options={})
  #    SectionTemplate.published.sequence_wise.find(:all,
  #      :select=>"section_templates.id AS section_id,section_templates.title AS section_title,resource_categories.title AS category_title,resource_categories.id AS category_id,resources.*",
  #      :joins=>"INNER JOIN item_templates ON item_templates.section_template_id=section_templates.id
  #  INNER JOIN resourcifications ON resourcifications.item_template_id = item_templates.id
  #  INNER JOIN resources ON resourcifications.resource_id = resources.id
  #  INNER JOIN resource_categories ON resources.resource_category_id = resource_categories.id#",
  #      :group=>"resources.id",
  #      :order=>"section_templates.id,resource_categories.title, resources.title",
  #      :limit=>options[:limit] || 3)
  #  end

end
