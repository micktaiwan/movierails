require 'openid'

class AccountController < ApplicationController
  layout  'login'
  include LoginSystem
  protect_from_forgery :only => [:index] 
  
  def index
     redirect_to :action => :login
  end

  def login
    #STDERR.puts "Login"
    case request.method
    when :post

      if params['openid_identifier'] != ''
        # http://openid-provider.appspot.com/foo@bar.com
        # http://openid-provider.appspot.com/faivrem
        open_id_authentication
        return
      end
    
      u = User.authenticate(params['user']['email'], params['user']['password'])
      if u
        session['user'] = u
        u.last_login = Time.now
        u.save
        # send an email to admin
        # AppMailer.deliver_alert("Login Alert","#{session['user']['name']} just logged on Movies")
        flash['notice']  = "Login successful"
        redirect_back_or_default :controller => "welcome"
      else
        @login    = params['user_login']
        @message  = "Login unsuccessful"
      end
    end
  end
  
  def openid
    open_id_authentication
  end
  
  
  def signup
    case request.method
      when :post
        @user = User.new(params['user'])
        if User.find_by_email(@user.email)
          flash['error']  = "Email already taken"
          return
        end   
        flash['error']  = ""
        if @user.save      
          session['user'] = User.authenticate(@user.email, params['user']['password'])
          AppMailer.deliver_alert("Registration Alert","#{session['user']['name']} just registered on Movies")
          #AppMailer.deliver_registration_mail(session['user']) #if not @user.email.blank?
          redirect_back_or_default :controller => "welcome"
        end
      when :get
        flash['error']  = ""
        #@user = User.new
    end      
  end  
  
  def delete
    #if params['id'] and session['user']
    #  @user = User.find(params['id'])
    #  @user.destroy
    #end
    #redirect_back_or_default :action => "welcome"
  end  
    
  def logout
    session['user']  = nil
    session['admin'] = nil
  end
  
  # send an email to reset the user password
  def send_reset_email
    begin
      email = params[:email]
      raise 'Invalid email' if(email=='')
      u = User.find_by_email(email)
      ok_msg = "Email sent, please check your mail."
      raise ok_msg if(u==nil)
      key = ApplicationHelper.generate_key
      u.update_attribute(:lost_key,key)    
      AppMailer.deliver_lost_password(u,key)
      render(:text=>ok_msg)
    rescue Exception => e
      render(:text=>e.message)
    end
  end
  
  # present a form to user to reset his pwd
  def reset
    @key = params[:id]
    if(@key==nil); redirect_to(:action=>:invalid_url); return; end
    # get key from db
    @user = User.find_by_lost_key(@key)
    # urls are valid 20 minutes
    #if @user!= nil and @user.updated_at < 20.minutes.ago
    #  @user.update_attribute(:lost_key,'')    
    #  @user = nil
    #end
    if(@user==nil); redirect_to(:action=>:invalid_url); return; end
  end

  def invalid_url
  end

  # Ajaxed
  def change_password
    begin
      key = params[:id]
      redirect_to(:action=>:invalid_url) if(key==nil)
      # get key from db
      @user = User.find_by_lost_key(key)
      raise 'You can not change your password here. Please go on the login page to do again the load password process.' if(@user==nil)
      @user.update_attribute(:lost_key,'') # the url is now invalid
      @user.update_attributes!(params[:pwd]) # raise an error if validation failed
      #@user.save! # to trigger before_update
      #session['user'] = u # uncomment if you want the user to login automatically
      render(:text => 'You can now log in with your new password')
    rescue Exception=>e
      render(:text=>e.message)
    end
  end
  
private   

  def open_id_authentication
    authenticate_with_open_id do |result, identity_url|
      if result.successful?
        if @current_user = User.find_by_identity_url(identity_url)
          successful_login
        else
          redirect_to("/openid/associate_login?iurl=#{identity_url}")
        end
      else
        failed_login result.message
      end
    end  
  end
  
  def successful_login
    session['user'] = @current_user
    redirect_to("/")
  end

  def failed_login(message)
    flash[:error] = message
    redirect_to("/")
  end
end

