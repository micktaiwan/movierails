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
    session['user'].movies << m
    render(:text=>"<b>Film ajout&eacute; : #{p['title']}</b>")
  end

  def add
    id = params['id'].to_i
    m = Movie.find(id)
    ms = session['user'].movies
    ms << m if not ms.include?(m)
    render(:partial=>"movie/my_movies", :collection=>session['user'].movies)
  end

end
