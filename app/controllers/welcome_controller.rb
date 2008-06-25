class WelcomeController < ApplicationController
  before_filter :login_required

	def index
		@my_movies = session['user'].movies
		@last = Movie.find(:all, :limit=>15, :order=>'created_at desc')
	end
	
end

