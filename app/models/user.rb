require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  has_many :opinions
	has_many :movies, :through=>:opinions, :select => "opinions.rating, opinions.comment, movies.*"
  
  def self.authenticate(email, pass)
    find(:first, :conditions=>["email=? AND password=?", email, sha1(pass)])
  end  
  
  protected
  
  def self.sha1(pass)
    Digest::SHA1.hexdigest("laphrasedelamort#{pass}quitue")
  end
  
  before_create :crypt_password
  before_update :crypt_password_on_update
  
  def crypt_password
    write_attribute("password", self.class.sha1(password))
  end
  
  #validates_uniqueness_of :email, :case_sensitive => false
  validates_presence_of :password, :password_confirmation, :if => :validate_password_confirmation?
  validates_confirmation_of :password,:if => :validate_password_confirmation?
  
  def crypt_password_on_update
    crypt_password if validate_password_confirmation?
  end
  
  def validate_password_confirmation?
    (password and password_confirmation)
  end  
  
end

