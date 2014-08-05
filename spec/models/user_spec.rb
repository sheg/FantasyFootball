require 'spec_helper'

describe User do

  before { @user = FactoryGirl.build :user }

  subject { @user }

  it { should be_valid }
  it { should respond_to(:email) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:address) }
  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:zip) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }

  describe "when email is not present" do
    before { @user.email = '' }
    it { should_not be_valid }
  end

  describe "when email is too long" do
    before { @user.email = "a@a.com" * 8 }
    it { should_not be_valid }
  end

  describe "when email address is already taken" do
    before do
      duplicate_user = @user.dup
      duplicate_user.save
    end
    it { should_not be_valid }
  end

  describe "when email address is already taken with different case" do
    before do
      duplicate_user = @user.dup
      duplicate_user.email = @user.email.upcase
      duplicate_user.save
    end
    it { should_not be_valid }
  end

  describe "when email address is not valid" do
    it "should not be valid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                   foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "when email address is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when password is not present" do
    before { @user = User.new(email: "test@test.com", password: "", password_confirmation: "" ) }
    it { should_not be_valid }
  end

  describe "when passwords don't not match" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password is too short" do
    before { @user.password = "a" * 5 }
    it { should_not be_valid}
  end

  describe "authentication" do
    before { @user.save }
    let(:found_user) { User.find_by(:email => @user.email) }

    describe "valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "invalid password" do
      let(:user_with_bad_password) { found_user.authenticate("invalidpassword") }
      it { should_not eq user_with_bad_password }
      specify { expect(user_with_bad_password).to be_false }
    end
  end

  describe "remember token" do
    before { @user.save }
    it { expect(@user.remember_token).not_to be_blank }
  end
end