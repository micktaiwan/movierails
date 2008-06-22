class WelcomeController < ApplicationController
  before_filter :login_required

	def index
		@my_movies = session['user'].movies
	end
	

end
