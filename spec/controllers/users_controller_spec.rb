require 'spec_helper'

describe UsersController do
  render_views
#  integrate_views

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
    end
    describe "as a non-signed-in user" do
      it "denies access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end
    describe "as a non-admin user" do
      it "protects the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end
    describe "as an admin user" do
      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
      end
      it "destroys the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end
      it "redirects to the users list" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end

  describe "GET 'index'" do
    describe "for non-signed-in user" do
      it "denies access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end
    describe "for signed-in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :email => "another@example.com")
        third = Factory(:user, :email => "anothe@example.net")
        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
      end
      it "is successful" do
        get :index
        response.should be_success
      end
      it "has the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end
      it "has an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
      it "paginates users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2", :content => "2")
        response.should have_selector("a", :href => "/users?page=2", :content => "Next")
      end
    end
  end
  
  describe "authentication of edit/update pages" do
    before(:each) do
      @user = Factory(:user)
    end
    describe "for non-signed-in users" do
      it "denies access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end
      it "denies access to 'update" do
        put :update, :id => @user, :user => { }
        response.should redirect_to(signin_path)
      end
    end
    describe "for signed-in users" do
      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end
      it "requires matching users for 'edit' " do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      it "requires matching users for 'update'" do
        put :update, :id => @user, :user => { }
        response.should redirect_to(root_path)
      end
      
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    describe "failure" do
      before(:each) do
        @attr = { :email => "", :name => "", :password => "", :confirmation => ""}
      end
      it "renders the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
      it "has the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end

    end
    describe "success" do
      before(:each) do
        @attr = { :email => "user@example.org", :name => "New Name", :password => "barbaz" , :confirmation => "barbaz"}
      end
      it "changes the user's attributes" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)
        @user.reload
        @user.name.should == user.name
        @user.email.should == user.email
      end
      it "redirects to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end
      it "has a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    it "is successful" do
      get :edit, :id => @user
      response.should be_success
    end
    it "has the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end
    it "has a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url, :content => "change")
    end
  end

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
