module ContactUsHelper
  def subject_choices
    Subject.contactus_subjects
  end
end
