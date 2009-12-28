# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  layout 'general'
  include LoginSystem
  
  before_filter :disable_link_prefetching
    
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '74f677e56719caa244301e7a8cd6a862'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  

private

   def disable_link_prefetching
      if request.env["HTTP_X_MOZ"] == "prefetch" 
         logger.debug "prefetch detected: sending 403 Forbidden" 
         render_nothing "403 Forbidden" 
         return false
      end
   end

end

class Fixnum
  def get_user
    User.find(self)
  end
end

