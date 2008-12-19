#require 'lib/proposer'
require 'linalg'

class MovieController < ApplicationController
  before_filter :login_required, :except => [:index, :last, :entry]
  protect_from_forgery :only => [:index] 

  def index
	  id = params[:id]
    @entry = (id==nil ? nil : Movie.find(id))
    return if not session['user']
    session['user']['page'] = 'last'
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
=begin  
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
=end

  def sugg
    # users = { 1 => "Ben", 2 => "Tom", 3 => "John", 4 => "Fred" }
    user = session['user']
    @users = User.find(:all,:conditions=>"id!=#{user.id}").map {|u| [u.id,u.name]}
    @users = Hash[*@users.collect { |v| [v[0], v[1]]}.flatten] # to hash
    
    movies = []
    Movie.find(:all,:order=>"id").each {|m| movies << m.user_matrix(user.id)}
    @movies = Linalg::DMatrix.rows(movies)

    # Compute the SVD Decomposition
    u, s, vt = @movies.singular_value_decomposition
    vt = vt.transpose
     
    # Take the 2-rank approximation of the Matrix
    #   - Take first and second columns of u  (6x2)
    #   - Take first and second columns of vt (4x2)
    #   - Take the first two eigen-values (2x2)
    u2 = Linalg::DMatrix.join_columns [u.column(0), u.column(1)]
    v2 = Linalg::DMatrix.join_columns [vt.column(0), vt.column(1)]
    eig2 = Linalg::DMatrix.columns [s.column(0).to_a.flatten[0,2], s.column(1).to_a.flatten[0,2]]
     
    # Here comes Bob, our new user
    bob = Linalg::DMatrix.rows( ([] << user.movie_matrix) )
    bobEmbed = bob * u2 * eig2.inverse
     
    # Compute the cosine similarity between Bob and every other User in our 2-D space
    user_sim, count = {}, 1
    v2.rows.each { |x|
        user_sim[count] = (bobEmbed.transpose.dot(x.transpose)) / (x.norm * bobEmbed.norm)
        user_sim[count] = 0 if user_sim[count].to_s == "NaN"
        count += 1
      }
     
    # Remove all users who fall below the 0.90 cosine similarity cutoff and sort by similarity
    @sim_users = user_sim.delete_if {|k,sim| sim < 0.9 }.sort {|a,b| b[1] <=> a[1] }
    @myItems = bob.transpose.to_a.flatten
    render(:partial=>'sugg.html.erb')
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
    movie = Movie.new(p) # TODO: verify that this exact title (and year) does not exists ?
    movie.title.strip!
    user  = session['user']
    op    = params['opinion']
    o     = Opinion.new(
      :user=>user,
      :movie=>movie,
      :comment=>op['comment'],
      :rating=>op['rating'].to_i
      )
    o.save # I don't know why I do not have to save the movie

    # urls
    names = params['name']
    urls = params['url']
    if names != nil
      names.each_with_index { |n,i|
        next if n == ''
        url = Url.new(
          :movie=>movie,
          :user=>user,
          :name=>n,
          :url=>urls[i]
          )
        url.save
        }
    end
    
    redirect_to(:action=>'index', :id=>movie.id)
  end

  def edit_comment_before_add
    id = params['id'].to_i
    movie = Movie.find(id)
    user  = session['user']
    if user.movies.include?(movie)
      render(:text=>"D&eacute;ja dans vos films...")
      return
    end
    urls = Url.find(:all,:conditions=>["movie_id=? and user_id=?",id,user.id])
    urls = []  if !urls
    render(:partial=>"add_form", :locals=>{:movie=>movie, :urls=>urls})
  end

  def edit_comment
    id = params['id'].to_i
    @opinion = Opinion.find(id)
    user = session['user']
    render(:text=>"Ce film n'est pas dans votre liste...") and return if @opinion.user_id != user.id
    #urls = Url.find_by_movie_id_and_user_id(id,user.id)
    urls = Url.find(:all,:conditions=>["movie_id=? and user_id=?",id,user.id])
    urls = []  if !urls
    render(:partial=>"add_form", :locals=>{:movie=>@opinion.movie, :urls=>urls})
  end

  def add
    id = params['movie']['id'].to_i
    movie = Movie.find(id)
    user  = session['user']
    op = params['opinion']
    o = Opinion.find(:first, :conditions=>["user_id = ? AND movie_id = ?", user['id'], id])
    if o
      o.attributes = op
      o.save
    else
      o = Opinion.new(
        :user=>user,
        :movie=>movie,
        :comment=>op['comment'],
        :rating=>op['rating'].to_i
        )
      o.save
    end
    
    # urls
    names = params['name']
    urls = params['url']
    if names != nil
      names.each_with_index { |n,i|
        next if n == ''
        url = Url.new(
          :movie=>movie,
          :user=>user,
          :name=>n,
          :url=>urls[i]
          )
        url.save
        }
    end
    redirect_to(:action=>'index', :id=>id)
  end
  
  def remove
    Opinion.find(:first, :conditions=>["user_id = ? AND movie_id = ?", session['user']['id'], params[:id]]).destroy
    render(:text=>"Ce film a &eacute;t&eacute; retir&eacute; de votre liste!")
  end
  
  def entry
    @entry = Movie.find(params[:id], :include=>"opinions")
    @user = session['user']
    if session['user']
      my = session['user'].movies.include?(@entry)
    else
      my = nil
    end
    render(:partial=>'entry', :locals=>{:my=>my})
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
		@movies -= session['user'].movies if session['user'] and session['user']['include_mine'] == false
  end

end

