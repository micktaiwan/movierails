class MovieController < ApplicationController

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
    redirect_to(:action=>'update_all', :id=>m.id)
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
    redirect_to(:action=>'update_all', :id=>id)
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
  
  def update_all
 	  id = params[:id]
    @entry = (id==nil ? nil:Movie.find(id))
    @my_movies = session['user'].movies
		@last = Movie.find(:all, :limit=>15, :order=>'created_at desc')
 		render(:template=>'welcome/index', :layout=>false)
  end
  
end
