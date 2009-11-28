class MyinfoController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token

  def index
    @user = session['user'].get_user
  end

  verify :method => :post, :only => [:update ], :redirect_to => { :action => :index }

  # Ajaxed
  def update
    begin
      u = session['user'].get_user
      u.update_attributes!(params[:user]) # raise an error
      render(:text=>'0')
    rescue Exception=>e
      render(:text=>e.message)
    end
  end
   
end

