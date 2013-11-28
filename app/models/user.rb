class User < ActiveRecord::Base
  has_many :teams
  has_many :leagues, :through => :teams

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :uniqueness => true, :presence => true, :format => { :with => VALID_EMAIL_REGEX }

end