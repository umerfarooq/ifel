class StaticController < ApplicationController
#  caches_page :alert
  
  def alert
    render :partial => 'alert_box'
    $success_for_blog = $error_for_blog = nil
  end

end
