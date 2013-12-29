class Todo < ActiveRecord::Base
  belongs_to :section

  named_scope :upcoming, :order => "due_date ASC"
  named_scope :are_not_in_past, :conditions => ['todos.due_date >=?', Date.today]
  named_scope :are_not_completed, :conditions => {:is_completed => false}
  named_scope :only, lambda{ |number| {:limit => number} }
  
end
