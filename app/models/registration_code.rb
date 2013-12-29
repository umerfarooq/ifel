class RegistrationCode < ActiveRecord::Base
  belongs_to :state
  has_many :users
  
  validates_presence_of :code
  
  before_create :set_creation_defaults
  
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
  
  def self.is_valid_code?(code)
    if RegistrationCode.find_by_code_and_state_id(code, State.activated.id)
      return true
    end
    return false
  end
  
  private
  def set_creation_defaults
    self.state = State.inactivated
  end
end
