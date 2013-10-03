class HomeController < ApplicationController

  def index

  end

  def search
    @users = User.all.paginate(:per_page => 5, :page => params[:page])
    
    respond_to do |format|
      format.html { @users}
      format.json { render json: @users }
    end
    
  end
end
