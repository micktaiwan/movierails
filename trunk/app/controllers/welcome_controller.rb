class WelcomeController < ApplicationController
  before_filter :login_required

	def index
		#u = session['user']
	end
	

end
