class UserSession < Authlogic::Session::Base
  self.logout_on_timeout=true
  self.remember_me=true
end