# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'login_engine'
  
 
class ApplicationController < ActionController::Base
  include LoginEngine
  helper :all # include all helpers, all the time
  layout 'general'

  #helper :user
  model :user
    
  before_filter :login_required
  
    
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '74f677e56719caa244301e7a8cd6a862'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  
  
end

