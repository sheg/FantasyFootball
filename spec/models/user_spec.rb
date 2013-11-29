require 'spec_helper'

describe User do

  before { @user = User.new(email: "test@test.com") }

  subject { @user }

  it { should be_valid }
  it { should respond_to(:email) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:address) }
  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:zip) }

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
end