class UserMailer < ActionMailer::Base
  default from: "forkoshd@gmail.com"

  def signup_success(user)
    @user = user
    mail to: @user.email, subject: "Welcome to Fantasy Football!"
  end
end