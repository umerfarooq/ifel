class Partner < ActiveRecord::Base
  belongs_to :state
  before_save :description_to_html, :absolutify_url
  before_create :set_creation_defaults

  has_attached_file :logo, :styles => { :small => "125x75", :medium => "150x100", :large => "200x100" },
    :url => "/admin/partners/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/partners/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/partners/:attachment/missing_:style.png"

  #attr_accessible         :company_name, :url, :description, :logo
  validates_presence_of   :company_name, :list_title,:show_title, :summary, :description
  validates_length_of     :company_name,  :in => 2..250,    :allow_blank => false
  #validates_length_of     :url,           :in => 2..250,    :allow_blank => false
  validates_length_of     :description,   :in => 2..65000,  :allow_blank => false

  validates_attachment_presence     :logo
  validates_attachment_size         :logo, :less_than => 1.megabytes
  validates_attachment_content_type :logo, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.logo_file_name.blank? }

  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :date_wise, :order => 'updated_at DESC'

  attr_accessor :first_show_title, :second_show_title


  def description_to_html
    self.description = self.description.gsub("\n", '<br />')
  end

  def set_creation_defaults
    self.state = State.inactivated
  end

  def absolutify_url
    unless self.url.blank? or self.button_url.blank?
      if !self.url.include?('http://') and !self.url.include?('https://')
        self.url = 'http://'.concat(self.url.to_s)
      end
      if !self.button_url.include?('http://') and !self.button_url.include?('https://')
        self.button_url = 'http://'.concat(self.button_url.to_s)
      end
    end
  end

  def join_detail_page_titles(first_show_title, second_show_title)
    show_title = nil
    unless first_show_title.blank?
      show_title = first_show_title.concat('<br />')
      show_title = first_show_title.concat(second_show_title) unless second_show_title.blank?
    end
    self.show_title = show_title
  end

  def split_detail_page_title
    title_array = self.show_title.split('<br />')
    self.first_show_title = title_array[0]
    self.second_show_title = title_array[1]
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

  def self.size_list
    ['small','medium','large']
  end
end
