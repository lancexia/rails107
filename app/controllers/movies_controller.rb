class MoviesController < ApplicationController
  before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy, :join, :quit]
  before_action :find_movie_and_check_permission, only: [:edit, :update, :destroy]


  def index
    @movies = Movie.all
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    @movie.user = current_user
    if @movie.save
     current_user.join!(@movie)
     redirect_to movies_path
     flash[:notice] =  "生成新电影"
    else
      render :new
    end
  end

  def show
    @movie = Movie.find(params[:id])
    @reviews = @movie.reviews.rescent.paginate(:page => params[:page], :per_page => 5)
  end

  def edit
  end

  def update
    if @movie.update(movie_params)
      redirect_to movies_path, notice: "Update Success"
    else
      render :edit
    end
  end

  def destroy
    @movie.destroy
    redirect_to movies_path, alert: "Movie Deleted"
  end

  def join
    @movie = movie.find(params[:id])

     if !current_user.is_member_of?(@movie)
       current_user.join!(@movie)
       flash[:notice] = "加入本讨论版成功！"
     else
       flash[:warning] = "你已经是本讨论版成员了！"
     end

     redirect_to movie_path(@movie)
   end

   def quit
     @movie = movie.find(params[:id])

     if current_user.is_member_of?(@movie)
       current_user.quit!(@movie)
       flash[:alert] = "已退出本讨论版！"
     else
       flash[:warning] = "你不是本讨论版成员，怎么退出 XD"
     end

     redirect_to movie_path(@movie)
   end






  private

  def find_movie_and_check_permission
    @movie = Movie.find(params[:id])
    if current_user != @movie.user
      redirect_to root_path, alert: "you have no permission"
    end
  end

  def movie_params
    params.require(:movie).permit(:title, :description)
  end





end
