module UsersHelper
  def helper_get_business_idea(user)
    user.business_idea
  end
  
  def wibo_affiliation
    [ ["Charlottesville, VA", 'VA'],
      ["Pittsburgh, PA", 'PA'],
      ["St Louis, MO", 'MO'],
      ["Bridgeport, CT", 'CT'],
      ["Harlem, NYC", 'Harlem'],
      ["Washington Heights, NYC", 'Washington Heights'],
      ["Long Island City, NYC", 'Long Island City'],
      ["Financial District, NYC", 'Financial District'],
      ["Lower East Side, NYC", 'Lower East Side'], 
      ["Downtown Brooklyn, NYC", 'Downtown Brooklyn'],      
      ["Central Brooklyn, NYC", 'Central Brooklyn']
    ]    
  end
  
  def academic_statuses
    [ 
      ["Undergraduate", 'Undergraduate'],
      ["Graduate", 'Graduate'],
      ["Alumna/Alumnus", 'Alumna/Alumnus'],
      ["Faculty", 'Faculty'],
      ["Staff", 'Staff'],
      ["Other", 'Other']
      
    ]
  end
  
  def sources
    [ 
      ["Word of Mouth", 'Word of Mouth'],
      ["Staff", 'Staff'],
      ["E-mail", 'E-mail'],
      ["Ad", 'Ad'],
      ["Website", 'Website'],
      ["Other", 'Other'] 
    ]
  end
end
