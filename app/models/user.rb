class User < ActiveRecord::Base
  before_save { self.email = email.downcase}
  has_many :teams
  has_many :leagues, :through => :teams

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :uniqueness => true,
            :presence => true, :length => { maximum: 50 },
            :format => { :with => VALID_EMAIL_REGEX }

end



