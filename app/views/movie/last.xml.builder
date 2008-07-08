xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title("Movies - RSS des derniers films")
    xml.link("http://movies.protaskm.com/")
    xml.description("Movies")
    xml.language('en-us')
      for m in @movies
        xml.item do
          xml.title(m.title)
          xml.description(m.title)
          #xml.author(m.director)               
          xml.pubDate(m.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
          xml.link("http://movies.protaskm.com/movie/index/#{m.id}")
          #xml.guid("http://movies.protaskm.com/movie/index/#{m.id}")
        end
      end
  }
}

