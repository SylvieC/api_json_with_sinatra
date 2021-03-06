
require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'

get '/' do
  html = %q(
  <html><head><title>Movie Search</title></head><body>
  <h1>Find a Movie!</h1>
  <form accept-charset="UTF-8" action="/result" method="post">
    <label for="movie">Search for:</label>
    <input id="movie" name="movie" type="text" />
    <input name="commit" type="submit" value="Search" /> 
  </form></body></html>
  )

end

post '/result' do
  search_str = params[:movie]

  # Make a request to the omdb api here!
  response = Typhoeus.get("www.omdbapi.com/", :params => {:s => search_str})
  result = JSON.parse(response.body)  
  
  
  
  # Modify the html output so that a list of movies is provided.
  html_str = "<html><head><title>Movie Search Results</title></head><body><h1>Movie Results</h1>\n<ul>"
  # I wanted to create a movie hash where for each movie year is the key, and the value is
  # an array of hashes { 2006 => [{"Title => " ", "imdbID} => "  "} {"Title" => , "imdbID" => }], 1665 => ..}
  # but I realized it is much better to just use sort_by
  sorted_by_year_hash = result["Search"].sort_by{|movie_hash| movie_hash["Year"]}
  sorted_by_year_hash.each do|movie_hash|   
  html_str += "<li><a href='/poster/#{movie_hash["imdbID"]}'>Title: #{movie_hash["Title"]}, Year: #{movie_hash["Year"]}</a></li>"
  end
  html_str += "</ul></body></html>" 
end

get '/poster/:imdb' do |imdb_id|
  # Make another api call here to get the url of the poster.
  id = params[:imdb]
  answer = Typhoeus.get("www.omdbapi.com/", :params => {:i => id})
  what_i_want = JSON.parse(answer.body)

  html_str = "<html><head><title>Movie Poster</title></head><body><h1>Movie Poster</h1>\n"
  html_str = "<h3><img src=#{what_i_want["Poster"]}></h3>"
  html_str += '<br /><a href="/">New Search</a></body></html>'

end

