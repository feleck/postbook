require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do
    before (:each) do
      @user = Factory(:user)
    end
    it "is successful" do
      get :show, :id => @user
      response.should be_success
    end
    it "finds the right user " do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    it "has the right title" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end
    it "has a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end

  end

  describe "GET 'new'" do
    it "is successful" do
      get :new
      response.should be_success
    end

    it "has the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end
  end

end
