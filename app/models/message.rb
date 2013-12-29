class Message < ActiveRecord::Base
  acts_as_commentable
  acts_as_followable
  acts_as_likeable

  belongs_to :user
  belongs_to :project
  #  belongs_to :message_category
  belongs_to :section_template
  
  has_many :comments, :dependent => :destroy
  has_many :inappropriates, :as => :appropriable
  has_many :message_ratings , :dependent => :destroy                                          # TODO [11/6/10 1:44 PM] => CHECK_IT EXTRA
  has_many :raters, :through => :message_ratings, :source => :user    # TODO [11/6/10 1:44 PM] => CHECK_IT EXTRA
  has_and_belongs_to_many :topics
  has_many :subject_following, :as => :subject

  before_create :set_creation_defaults

  #attr_accessible :title, :body, :is_admin_only
  validates_presence_of :body
  validates_presence_of :section_template
  #  validates_presence_of :message_category, :unless => "is_admin_only"

  named_scope :appropriate, :conditions => {:is_appropriate => true}
  named_scope :for_admin, :conditions => {:is_admin_only => true}
  named_scope :not_for_admin, :conditions => {:is_admin_only => false}
  named_scope :date_wise, :order => 'created_at DESC'
  named_scope :view_count_wise, :order => 'view_count DESC'
  named_scope :limit_popular, :limit => MESSAGES_POPULAR_TOPICS_COUNT
  named_scope :limit_launchpad, :limit => FRONT_MODULES_MESSAGES_COUNT
  named_scope :for_user, lambda { |user_id| {:conditions => ["(is_admin_only = ?) OR (user_id = ?)", false, user_id]} }
  named_scope :only,lambda {|number| {:limit => number}}

  #  def comments_for(someone)    # self.comments.appropriate.for_user(someone)   # using name_scopes from Comment model
  #    RAILS_DEFAULT_LOGGER.debug "_______________________C__________________________________"
  #    if someone.id == self.user_id
  #      return self.comments.find_all_by_is_appropriate(true, :order => 'created_at DESC')
  #    RAILS_DEFAULT_LOGGER.debug "_______________________C__________________________________"
  #    else
  #      cfso = []
  #      self.comments.find_all_by_is_appropriate(true, :order => 'created_at DESC').each do |c|
  #        if c.is_private
  #          cfso << c if(c.user_id == someone.id)
  #        else
  #          cfso << c
  #        end
  #    RAILS_DEFAULT_LOGGER.debug "_______________________C__________________________________"
  #      end
  #      return cfso
  #    end
  #  end
  def deliver_comment_on_message_email_in_model(comment)
    UserMailer.deliver_comment_on_message_email(self.user, comment)
  end

  def deliver_edit_message_email_to_followers
    followers = Follow.find_all_by_followable_type_and_followable_id("Message",self.id)
    followers.each do |follow|
      user = User.find(follow.follower_id)
      UserMailer.deliver_edit_message_email_to_followers(user, self)
    end
  end

  def deliver_message_posted_email
    UserMailer.deliver_message_posted_email(User.with_role("moderator"), self)
    #    RAILS_DEFAULT_LOGGER.info "__#{User.with_role("moderator").map {|mod| "#{mod.first_name} #{mod.last_name} <#{mod.email}>"}}__"
  end

  def unanswered_inappropriate_by?(someone)
    Inappropriate.find_by_appropriable_id_and_appropriable_type_and_user_id_and_is_answered(self, self.class.to_s, someone, false).blank? == false
  end

  def mark_inappropriate_by(someone)
    return false unless Inappropriate.find_by_appropriable_id_and_appropriable_type_and_user_id_and_is_answered(self, self.class.to_s, someone, false).blank?
    inappropriate = Inappropriate.new
    inappropriate.user = someone
    inappropriate.appropriable = self
    inappropriate.is_answered = false
    inappropriate.save
  end

  def reviewed_by!(someone)
    self.view_count = self.view_count + 1
    #    new_comments = self.comments.find_all_by_is_appropriate_and_is_new(true, true)
    #    new_comments.each { |nc| nc.viewed! }
    self.comments.find_all_by_is_appropriate_and_is_new(true, true).each { |comment| comment.viewed! } if self.user == someone
    self.save
  end

  def self.search_messages(options, request)
    #sections = @current_user.project.sections
    query = options["search_que"]
    search_results = Message.search(
      query,
      #:conditions => {:documentable_type => 'Section'},
      #:with_all => {:documentable_id => sections.collect(&:id)},
      :retry_stale => true)
    SearchTerm.searched(query, request.referer, 'internal')
    return search_results
  end

  #  def self.search_messages_on_topic(options, request)
  #    query = options["topic"]
  #  end

  def self.recent_message_of_user(user)
    user.messages.date_wise.only 1
    #    return User.find(user.id).messages.find(:all, :order=> "created_at desc",:limit=>1)
  end

  def self.recent_message_or_comment_of_user(user)
    comment_message = user.messages.find(:first, :select => 'messages.*, comments.created_at AS created_date',
      :joins=>"INNER JOIN comments ON comments.message_id = messages.id",
      :order=>"comments.created_at DESC")
    message = user.messages.find(:first,:select=>'*, created_at AS created_date',:order=>'created_at DESC')
    if comment_message and message
      return (comment_message.created_date > message.created_date) ? comment_message : message
    else
      return (comment_message.blank?) ? message : comment_message
    end
    nil
  end

  def self.recent_messages(offset=0,limit=11)#(is_first_time, last_message_id)
    Message.all(:order=> 'id desc', :offset=>offset ,:limit=>limit)
  end
  
  def self.create_message(params, current_user)
    section = SectionTemplate.find_by_id params[:message][:section_template_id].to_i
    if params[:message][:item_template_id].present?
      item_template = ItemTemplate.find(params[:message][:item_template_id]) 
      params[:message].delete(:item_template_id)
    end
    topics = Array.new
    if params[:message][:topics].present?
      topic_ids = params[:message][:topics].split(',')
      topic_ids.each do |t|
        topics << Topic.find(t.to_i)
      end
      params[:message].delete(:topics)
    end
    section.default_topics.each do |t|
      if t.is_published?
        topic = Topic.find(t.topic_id)
        topics << topic if topic.is_published?
      end
    end
    unless item_template.blank?
      item_template.default_topics.each do |t|
        if t.is_published?
          topic = Topic.find(t.topic_id)
          topics << topic if topic.is_published?
        end
      end
    end
    message = Message.new(params[:message])
    message.body.gsub!("\r\n","<br />")
    message.section_template = section
    message.user = current_user
    message.project = current_user.project
    message.topics = topics unless topics.blank?
    if message.save
      User.send_message_email_to_community_expert({:section_id => section.id,:section_title => section.title, :message_id => message.id})
    end
  end

  def update_topic(params)
    topics = Array.new
    topic_ids = params[:topics].split(',')
    topic_ids.each do |t|
      topics << Topic.find(t.to_i)
    end
    self.topics = topics
    self.save
  end

  def update_message_body(params)
    body = params[:body]
    self.update_attribute(:body, body)
    #    self.body=params[:body]
    #    self.save()
  end

  def search
    @search_results = Message.search_messages(params, request)
    if request.xhr?
      render :partial => "search_result", :locals => { :messages => @search_results}
    end
  end

  def latest_comments(current_user)
    self.comments.for_message.for_user(current_user).datewise
  end

  def deliver_following_a_question_email(user)
    UserMailer.deliver_following_a_question_email(user, self)
  end

  def self.most_recent_and_similar_tagged_activities(item_template_id)
    Message.find(:all,
      :select=> 'messages.id,messages.body,messages.user_id,messages.created_at,topics.name as topic_name',
      :joins => "INNER JOIN messages_topics ON messages_topics.message_id=messages.id
                 INNER JOIN topics ON messages_topics.topic_id=topics.id
                 INNER JOIN item_templates_topics ON item_templates_topics.topic_id=topics.id",
      :conditions=>{'item_templates_topics.item_template_id'=> item_template_id},
      :order => "messages.created_at desc",
      :limit => 4)
  end

  def self.most_recent_section_template_activities(section_template_id)
    Message.find(:all,
      :select=> 'id,body,user_id,created_at',
      :conditions=>{'section_template_id'=> section_template_id},
      :order => "messages.created_at desc",
      :limit => 4)
  end



  def self.load_questions(term)
    Message.find(:all, :select=>'body', :conditions => ['body LIKE(?)',"%#{term}%"]).map { |x| x.body }.to_json
  end


  define_index do
    indexes title
    indexes body
    indexes topics(:name)
    set_property :delta => true
  end

  private
  def set_creation_defaults
    self.is_appropriate = true
    self.thumbs_up = 0
    self.thumbs_down = 0
    self.rating = 0
    self.view_count = 0
  end

end
