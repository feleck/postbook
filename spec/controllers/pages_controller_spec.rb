require 'spec_helper'

describe PagesController do
# added:
  render_views

  describe "GET 'home'" do
    it "is successful" do
      get 'home'
      response.should be_success
    end

    it "has the right title" do
      get 'home'
      response.should have_selector("title", :content => "PostBook App | Home")
    end
  end

  describe "GET 'contact'" do
    it "is successful" do
      get 'contact'
      response.should be_success
    end
    it "has the right title" do
      get 'contact'
      response.should have_selector("title", :content => "PostBook App | Contact")
    end
  end

  describe "GET 'about'" do
    it "is successful" do
      get 'about'
      response.should be_success
    end
    it "has the right title" do
      get 'about'
      response.should have_selector("title", :content => "PostBook App | About")
    end
  end
  
end


