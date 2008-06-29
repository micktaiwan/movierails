class Movie < ActiveRecord::Base
  has_many :opinions
	has_many :users, :through=>:opinions
	
	def rating
	# TODO: cache the rating !
    nb = 0
    sum = 0.0
    Opinion.find(:all, :conditions=>["movie_id = ?",self.id]).each { |o|
      if o.rating and o.rating > 0
        nb += 1
        sum += o.rating
      end  
      }
    return sprintf("%0.3f",sum / nb).to_f if nb > 0
    return 0
	end
	 
end

