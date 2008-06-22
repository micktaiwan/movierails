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
    render(:text=>"<b>Film ajout&eacute; : #{p['title']}</b>")
  end

  def edit_comment_before_add
    id = params['id'].to_i
    m = Movie.find(id)
    u = session['user']
    if u.movies.include?(m)
      render(:text=>"Deja dans vos films...")
      return
    end
    render(:partial=>"add_form", :locals=>{:movie=>m})
  end

  def add
    id = params['movie']['id'].to_i
    m = Movie.find(id)
    u = session['user']
    if u.movies.include?(m)
      render(:text=>"Deja dans vos films...")
      return
    end
    
    op = params['opinion']
    o = Opinion.new(
      :user=>u,
      :movie=>m,
      :comment=>op['comment'],
      :rating=>op['rating'].to_i
      )
    o.save
    render(:text=>"Ajout&eacute; !")
    #render(:partial=>"movie/my_movies", :collection=>session['user'].movies)
  end

end
