require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  has_many :opinions
	has_many :movies, :through=>:opinions, :select => "opinions.rating, opinions.comment, movies.*"
	has_many :urls
  
  #validates_uniqueness_of :email, :case_sensitive => false
  validates_presence_of :password, :password_confirmation, :if => :validate_password_confirmation?
  validates_confirmation_of :password,:if => :validate_password_confirmation?

  before_create :crypt_password
  before_update :crypt_password_on_update

  def self.authenticate(email, pass)
    find(:first, :conditions=>["email=? AND password=?", email, sha1(pass)])
  end  
  
  def movie_matrix
    sql = ActiveRecord::Base.connection();
    rv = []
    rows  = sql.execute("select m.id, o.rating from movies m left outer join opinions o on o.movie_id = m.id and o.user_id= #{self.id} order by m.id")
    while true
      id, rating = rows.fetch_row
      break if id == nil
      rv << (rating==nil ? 0:rating.to_i)
    end
    rv
  end

  protected
  
  def self.sha1(pass)
    Digest::SHA1.hexdigest("laphrasedelamort#{pass}quitue")
  end
  
  def crypt_password
    write_attribute("password", self.class.sha1(password))
  end
  
  
  def crypt_password_on_update
    crypt_password if validate_password_confirmation?
  end
  
  def validate_password_confirmation?
    (password and password_confirmation)
  end  
  
end

