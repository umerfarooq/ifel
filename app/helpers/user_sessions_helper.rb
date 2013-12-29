module UserSessionsHelper
  def login_title
    if @new_login
      "Login"
    else
      "Incorrect Login"
    end
  end

  def login_headline
    if @new_login
      nil
    else
      %Q~<h2 class="headLine">Did you type in the wrong username or password?</h2>~
    end
  end

  def login_message
    if @new_login
      "Please provide your Berkley Center's username and password to sign-in."
    else
      "The login information provided does not match what we have on record. Please check to make sure the information is correct and try again."
    end
  end
end
