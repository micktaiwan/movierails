class UrlController < ApplicationController

  def create_form
    render(:partial=>'create_form')
  end

  def del
    id = params[:id].to_i
    Url.find(id).destroy
    render(:text=>'Supprim&eacute;')
  end
  
end

