class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_logged_in

  protected

  def current_identity
    @current_identity ||= session[:current_identity]
  end

  helper_method :current_identity, :session_aliases


  def current_identity=(identity)
    identity.use
    session[:current_identity] = identity
  end

  def check_logged_in
    if current_identity.nil?
      identity = Identity.create_from_hash({"provider"=>"facebook", "uid"=>"100000895882769", "credentials"=>{"token"=>"140316859358580|77602e71b789df7f34f0b2a8.1-100000895882769|JmfXbmcq509B1EI7SkYcbnPocM4"}, "user_info"=>{"nickname"=>"profile.php?id=100000895882769", "first_name"=>"Pyotr", "last_name"=>"Koryakin", "name"=>"Pyotr Koryakin", "urls"=>{"Facebook"=>"http://www.facebook.com/profile.php?id=100000895882769", "Website"=>nil}}, "extra"=>{"user_hash"=>{"id"=>"100000895882769", "name"=>"Pyotr Koryakin", "first_name"=>"Pyotr", "last_name"=>"Koryakin", "link"=>"http://www.facebook.com/profile.php?id=100000895882769", "gender"=>"male", "email"=>"ortepko@gmail.com", "timezone"=>3, "locale"=>"ru_RU", "verified"=>true, "updated_time"=>"2011-04-22T11:46:04+0000"}}})
      unless identity["identityID"].nil?
        identity.use
        session[:current_identity] = identity
      end
    end
  end

end
