class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome #{@user.first_name} to Fantasy Football!"
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