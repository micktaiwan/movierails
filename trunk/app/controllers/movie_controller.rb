#require 'lib/proposer'

class MovieController < ApplicationController
  before_filter :login_required, :except => [:last]
  protect_from_forgery :only => [:index] 

  def index
    session['user']['page'] = 'last'
	  id = params[:id]
    @entry = (id==nil ? nil : Movie.find(id))
    get_movies
		@movies = @movies[0..14]
  end
  
  def display_list
    session['user']['page'] = 'last' if session['user']['page'] == nil
    redirect_to(:action=>session['user']['page'])
  end
 
  def last
    respond_to do |format|
      format.xml {
		    @movies = Movie.find(:all, :limit=>15, :order=>'created_at desc')
		    render :template => 'movie/last.xml.builder', :layout => false
		    }
		  format.html {
        session['user']['page'] = 'last'
        get_movies
		    @movies = @movies[0..14]
        render(:partial=>'last', :collection=>@movies)
		    }  
		end    
  end
  
  def best
    session['user']['page'] = 'best'
    get_movies
		@movies = @movies.sort_by{ |m| [-m.rating,-m.opinions.size]}[0..14]
    render(:partial=>'last', :collection=>@movies)
  end
  
  def most_watched
    session['user']['page'] = 'most_watched'
    get_movies
		@movies = @movies.sort_by{ |m| [-m.opinions.size,-m.rating]}[0..14]
    render(:partial=>'last', :collection=>@movies)
  end
  
  def sugg
    session['user']['page'] = 'sugg'
		#m = Movie.find(:all)
    #u = User.find(:all)
    user = session['user']
    p = Proposer.new
    #p.use_item_weight = true
    p.db = Opinion.find(:all).map { |o| [o.user, o.movie]}
    str = "<b>En test !</b><br/><br/>"
    p.propose(user)
    str += "user #{user.name} items: #{p.user_items.collect{|m| m.title}.join(', ')}<br/>"
  	p.items.each { |u,c|
  		str += "item #{u.title} is owned by #{c} users other than user #{user.name}<br/>"
  		}
  	p.users.each { |u,c|
  		str += "user <b>#{u.name}</b> has #{c} item in common, and has a weight of #{c}<br/>"
  		str += "items: "+p.get_items(u,[]).collect{|m| m.title}.join(',') + "<br/>"
  		}
  	str += "<br/>"
  	str += "Finally here is the list of proposed items for user #{user.name}<br/>"
  	p.proposed_items.each { |item,count|
  		str += "#{item.title} has a weight of #{count}<br/>"
  		}
  	str += "<br/><b>En enlevant les navets, ca fait au final:</b><br/>"	
  	p.proposed_items.sort_by {|item,count| -item.rating}.each { |item,count|
  		str += "- <a href='/movie/index/#{item.id}'>#{item.title}</a> Note: #{item.rating}<br/>" if item.rating >= 3
  		}
    #render(:partial=>'last', :collection=>@movies)
    render(:text=>str)
  end
  
  def search_form
    render(:partial=>'search_form')
  end

  def search
    m = params['movie']
    t = m['title']
    movies = Movie.find(:all, :conditions=>"title like '%#{t}%' or director like '%#{t}%' or year like '%#{t}%'")
    if movies.size == 0
      render(:partial=>"create_form")
      return
    else
      render(:partial=>"search", :locals=>{:movies=>movies})
      return
    end
  end

  
  def create_form
    render(:partial=>'create_form')
  end

  def create
    p = params['movie']
    m = Movie.new(p)
    u = session['user']
    op = params['opinion']
    o = Opinion.new(
      :user=>u,
      :movie=>m,
      :comment=>op['comment'],
      :rating=>op['rating'].to_i
      )
    o.save
    #session['user'].movies << m
    #render(:text=>"<b>Film ajout&eacute; : #{p['title']}</b>")
    redirect_to(:action=>'index', :id=>m.id)
  end

  def edit_comment_before_add
    id = params['id'].to_i
    m = Movie.find(id)
    u = session['user']
    if u.movies.include?(m)
      render(:text=>"D&eacute;ja dans vos films...")
      return
    end
    render(:partial=>"add_form", :locals=>{:movie=>m})
  end

  def edit_comment
    id = params['id'].to_i
    @opinion = Opinion.find(id)
    u = session['user']
    if @opinion.user_id != u.id
      render(:text=>"Ce film n'est pas dans votre liste...")
      return
    end
    render(:partial=>"add_form", :locals=>{:movie=>@opinion.movie})
  end

  def add
    id = params['movie']['id'].to_i
    m = Movie.find(id)
    u = session['user']
    op = params['opinion']
    o = Opinion.find(:first, :conditions=>["user_id = ? AND movie_id = ?", u['id'], id])
    if o
      o.attributes = op
      o.save
    else
      o = Opinion.new(
        :user=>u,
        :movie=>m,
        :comment=>op['comment'],
        :rating=>op['rating'].to_i
        )
      o.save
    end
    redirect_to(:action=>'index', :id=>id)
  end
  
  def remove
    Opinion.find(:first, :conditions=>["user_id = ? AND movie_id = ?", session['user']['id'], params[:id]]).destroy
    render(:text=>"Ce film a &eacute;t&eacute; retir&eacute; de votre liste!")
  end
  
  def entry
    @entry = Movie.find(params[:id])
    opinions = @entry.opinions
    my = session['user'].movies.include?(@entry)
    render(:partial=>'entry', :locals=>{:opinions=>opinions, :my=>my})
  end
  
  def include_mine
    i = params['i'].to_i
    session['user']['include_mine'] = i
    u = User.find(session['user'].id)
    u.include_mine = i
    u.save
    #render(:text=>session['user']['include_mine'])
    redirect_to(:action=>'display_list')
  end
  
private

  def get_movies
		@movies = Movie.find(:all,:order=>'movies.created_at desc')
		@movies -= session['user'].movies if session['user']['include_mine'] == false
  end

end
