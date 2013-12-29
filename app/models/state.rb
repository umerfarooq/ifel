class State < ActiveRecord::Base
  has_many :marketing_text_messages
  has_many :document_categories
  has_many :news_items
  has_many :news_categories
  has_many :success_stories
  has_many :message_categories
  has_many :biographies
  has_many :partners
  has_many :faqs
  has_many :questions
  has_many :promotions
  has_many :events
  has_many :events_providers
  has_many :documents
  has_many :topics
  has_many :mentors
  has_many :registration_codes

  def is_inactivated?
    self.name == "inactivate" || self.title == "Inactivated"
  end

  def is_activated?
    self.name == "activate" || self.title == "Activated"
  end

  def is_published?
    self.name == "publish" || self.title == "Published"
  end

  def is_featurified?
    self.name == "featurify" || self.title == "Featurified"
  end

  def is_inprogress?
    self.name == "inprogress" || self.title == "In-Progress"
  end

  def is_completed?
    self.name == "complete" || self.title == "Completed"
  end

  def State.inactivated
    State.find_by_name("inactivate")
  end

  def State.activated
    State.find_by_name("activate")
  end

  def State.published
    State.find_by_name("publish")
  end

  def State.featurified
    State.find_by_name("featurify")
  end

  def State.inprogress
    State.find_by_name("inprogress")
  end

  def State.completed
    State.find_by_name("complete")
  end

end
