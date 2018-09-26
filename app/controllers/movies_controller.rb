class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
    # Because I have problems with keeping sorting, I'll force it to change when needed
    if(session[:sort] && params[:sort]==nil ); params[:sort]=session[:sort] else session[:sort]=params[:sort] end
    
    # I used: https://stackoverflow.com/questions/3976295/order-a-collection-as-desc
    # I also used (for added saftey): https://stackoverflow.com/questions/18441435/sort-alphabetically-in-rails?rq=1
    @all_ratings=Movie.order(:rating).map(&:rating).uniq.sort_by!{ |e| e.downcase }
    (params[:ratings] ? params[:ratings].keys : @all_ratings).each do |rating| params[rating]=true end

    # I used: https://www.tutorialspoint.com/ruby-on-rails/rails-session-cookies.htm
    # I also used: https://www.justinweiss.com/articles/how-rails-sessions-work/
    if ((session[:sort] || session[:ratings]) && !params[:sort] && !params[:ratings]); redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings]) end
    
    # I used: https://stackoverflow.com/questions/7236612/select-everything-in-a-database-where-order-by
    @movies = params[:sort] ? Movie.where(:rating => (params[:ratings] ? params[:ratings].keys : @all_ratings)).order(session[:sort]) : Movie.where(:rating => (params[:ratings] ? params[:ratings].keys : @all_ratings))
    session[:ratings], session[:sort]= params[:ratings], params[:sort]
  end
  
  

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
