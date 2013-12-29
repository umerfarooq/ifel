module ResourceCategoriesHelper
  def helper_page_title(message)
    (message.location == 'resource_library_image') ? 'Resource Library' : 'Service Provider'
  end
  
end
