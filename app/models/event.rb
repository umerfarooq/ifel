class Event < ActiveRecord::Base
  belongs_to :state
  belongs_to :event_category,:foreign_key => :event_category_id

  EVENTS_PAGE_WITH_IMAGES_COUNT = 2
  ABOUTUS_SIDEBAR_COUNT = 1
  HOME_PAGE_COUNT = 1

  before_create :set_creation_defaults
  before_save :validate_start_and_end_date

  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :featured, :conditions => {:state_id => State.featurified.id}
  named_scope :date_wise, :order => 'event_start_date ASC'
  named_scope :time_wise, :order => 'event_start_time ASC'
  named_scope :active_events, :conditions => ['event_start_date >? OR event_end_date >? OR (event_start_date =? AND event_start_time >=?) OR (event_end_date =? AND event_end_time >=?)',Date.today,Date.today,Date.today,Time.zone.now,Date.today,Time.zone.now]
  named_scope :future_events, :conditions => ['event_start_date >? OR (event_start_date =? AND event_start_time >=?)',Date.today,Date.today,Time.now]
#  named_scope :future_events_for_dashboard, :conditions => ['event_start_date >? OR (event_start_date =? AND event_start_time >=?)',Date.today,Date.today,Time.now], :limit=>4
  named_scope :internal, :conditions => {:is_internal => true}
  named_scope :external, :conditions => {:is_internal => false}
  named_scope :latest_event,lambda { |focused_event_id| {:conditions=>['id !=? and event_start_date >=? OR (event_start_date =? AND event_start_time >=?) OR event_end_date >=?  OR (event_end_date =? AND event_end_time >=?)',focused_event_id, Date.today,Date.today,Time.zone.now,Date.today,Date.today,Time.zone.now]} }

  has_attached_file :picture, :styles => {:large => "600x400>", :medium => "300x200>", :small => "200x150>" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png"

  attr_accessible :title, :event_start_date, :event_end_date, :event_start_time, :event_end_time, :city, :geo_state, :url, :is_internal, :rsvp, :description, :summary, :picture
  attr_accessor :event_start_min, :event_end_min, :event_start_meridlem, :event_end_meridlem, :same_as_start_date, :rss_provider

  validates_presence_of :title, :event_start_date, :event_end_date, :event_start_time, :city, :geo_state, :url, :description, :summary, :event_category_id
  #validates_uniqueness_of :event_end_time, :event_end_min, :allow_blank => true

  def validate_start_and_end_date
    self.errors.add(:event_start_date, "should not be in past") if self.event_start_date < Date.today
    self.errors.add(:event_end_date, "should not be in past") if self.event_end_date < Date.today
    self.errors.add(:event_end_date, "start date should not be after end date") if self.event_end_date <  self.event_start_date
    self.errors.add(:event_end_time, "end time should not be before start time") if (self.event_end_date == self.event_start_date and self.event_end_time < self.event_start_time)
    return self
  end

  def set_creation_defaults
    self.state = State.inactivated
  end

  def self.do_time_formations(options)
    build_event_end_date(options)
    options[:event_end_time] = (options[:event_end_time].blank? or options[:event_end_min].blank? or options[:event_end_meridlem].blank?) ? Time.parse("23:59:59").strftime("%H:%M:%S") : Event.build_event_time(options[:event_end_meridlem], options[:event_end_time], options[:event_end_min])
    options[:event_start_time] = Event.build_event_time(options[:event_start_meridlem], options[:event_start_time], options[:event_start_min])
    return options
  end

  def self.build_event_end_date(options)
    if options[:same_as_start_date]=='1'
      options['event_end_date(1i)'] = options['event_start_date(1i)']
      options['event_end_date(2i)'] = options['event_start_date(2i)']
      options['event_end_date(3i)'] = options['event_start_date(3i)']
    end
  end

  def self.build_event_time(meridlem, hour, minute)
    time = Event.convert_hour(meridlem, Integer(hour))
    time = time + ':' + minute + ':00'
    return Time.parse(time).strftime("%H:%M:%S")
  end

  def self.convert_hour(meridlem, hour)
    return (meridlem=='pm') ? ( (hour==12) ? hour.to_s : (hour+=12).to_s) : (hour==12) ? '00' : hour.to_s
  end

  def Event.for_about_us_with_images
    (Event.featured.date_wise.active_events + Event.published.date_wise.active_events)[0, EVENTS_PAGE_WITH_IMAGES_COUNT]
  end

  def Event.for_about_us_without_images
    (Event.featured.date_wise + Event.published.date_wise)[EVENTS_PAGE_WITH_IMAGES_COUNT..-1]
  end

  def Event.aboutus_sidebar_events
    Event.published.date_wise.active_events.all(:limit => ABOUTUS_SIDEBAR_COUNT)
  end

  def Event.home_page_events
    Event.published.date_wise.all(:limit => HOME_PAGE_COUNT)
  end

  def self.latest_event_other_than_focused_one(focused_event_id)
    Event.published.date_wise.latest_event(focused_event_id).first
  end

  def self.get_two_latest_events
    (Event.featured.date_wise.future_events + Event.published.date_wise.future_events)[0, EVENTS_PAGE_WITH_IMAGES_COUNT]
  end

  def self.recent_events
    (Event.get_two_latest_events + Feed.event_feeds.date_wise.future_event_feeds[0,2]).sort_by {|obj| Date.parse(obj.event_start_date.to_s)}[0,2]
  end
  
  def internal?
    self.is_internal == true
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

  def self.rsvp_options
    ['yes', 'no']
  end

  def self.size_list
    ['small', 'medium', 'large']
  end

end
