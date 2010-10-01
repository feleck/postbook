class SessionsController < ApplicationController

#  include SessionsHelper
  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'
    else
#      flash.now[:success] = "Successfuly signed in."
      sign_in user
      redirect_to user
#      flash.now[:success] = "Successfuly signed in."
      # signin the user and redirects to his show page
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
