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
  
  describe "POST 'create'" do
    describe "failure" do
      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => ""}
      end
      it "not creates a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
      it "has the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end
      
      it "renders the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :name => "New USer", :email => "user@dresik.com", :password => "foobar", :password_confirmation => "foobar"}
      end
      it "creates a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      it "redirects to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end
      it "has a welcome message" do
        post :create, :user => @attr
        flash[:success].should  =~ /welcome to the PostBook app/i
      end
      it "signs the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
            
    end
  end
end
