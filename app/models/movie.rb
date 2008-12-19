class Movie < ActiveRecord::Base
  has_many :opinions
	has_many :users, :through=>:opinions
  has_many :urls
  
	
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
  
  def user_matrix(for_user_id)
    sql = ActiveRecord::Base.connection();
    rv = []
    rows  = sql.execute("select u.id, o.rating from users u left outer join opinions o on o.movie_id = #{self.id} and o.user_id=u.id where u.id!='#{for_user_id}' order by u.id")
    while true
      id, rating = rows.fetch_row
      break if id == nil
      rv << (rating==nil ? 0:rating.to_i)
    end
    rv
  end
  
	 
end

