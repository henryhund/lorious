class HomeController < ApplicationController

  def index

  end

  def search
    @users = User.all.paginate(:per_page => 3, :page => params[:page])
  end
end
