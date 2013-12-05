class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome #{@user.first_name} #{@user.first_name}!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
  end

  def destroy
  end
end


private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email,
                                 :address, :city, :zip,
                                 :password, :password_confirmation)
  end