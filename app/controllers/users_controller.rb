class UsersController < ApplicationController
  before_action :signed_in_user, only: [:show, :edit, :update, :user_leagues]
  before_action :correct_user, only: [:show, :edit, :update, :user_leagues]

  def show
    @user_leagues = @user.leagues
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

  def edit
    render 'new'
  end

  def update
    if @user.update_attributes(edit_user_params)
      flash[:success] = "User updated successfully"
      redirect_to @user
    else
      render 'new'
    end
  end

  def destroy
  end

  def email_exists
    result = User.exists?(email: params[:email_address])
    result = 0 unless result
    render text: result
  end
end

private

  def correct_user
    @user = User.find_by(id: params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email,
                                 :address, :city, :zip,
                                 :password, :password_confirmation)
  end

  def edit_user_params
    params.require(:user).permit(:first_name, :last_name, :address, :city, :zip, :password, :password_confirmation)
  end