class WelcomeController < ApplicationController
  before_filter :login_required

	def index
	  id = params[:id]
    @entry = (id==nil ? nil : Movie.find(id))
		@my_movies = session['user'].movies
		@last = Movie.find(:all, :limit=>15, :order=>'created_at desc')
		@reviews = Opinion.find(:all, :include=>['movie','user'], :limit=>15, :order=>'created_at desc')
	end
	
end

