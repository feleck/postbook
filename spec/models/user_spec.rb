require 'spec_helper'

describe User do
  before (:each) do
    @attr = { 
      :name => "Example User", 
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  it "creates a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "requires a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "requires an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  
  it "requies names not too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "accepts valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.pl]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "rejects invalid emal addresses" do
    addresses = %w[user@foo,com THE_USER_at_foo.bar.org first.last@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "rejects duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "rejects email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "password validations" do
    it "requires a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end
    it "requires a matrching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).should_not be_valid
    end
    it "rejects short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end
    it "rejects long passwords" do
      long = "a" *41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do
    before (:each) do
      @user = User.create!(@attr)
    end
    it "has an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    it "sets the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
      it "is true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      it "is false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end
    describe "authenticate method" do
      it "returns nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end
      it "returns nil on email address with no user" do
        noexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        noexistent_user.should be_nil
      end
      it "returns the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end
  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end
    it "responds to admin" do
      @user.should respond_to(:admin)
    end
    it "is not an admin by default" do
      @user.should_not be_admin
    end
    it "is convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
    
end
