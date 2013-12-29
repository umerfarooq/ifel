module MentorsHelper
  def mentors
    Mentor.published.name_wise
  end
end
