class ExampleCategory < ActiveRecord::Base
  belongs_to :state

#  def ExampleCategory.all_active
#    ExampleCategory.find_all_by_state_id((State.find_by_title("create")).id)
#  end
end
