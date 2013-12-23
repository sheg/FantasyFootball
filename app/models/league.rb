class League < ActiveRecord::Base
  has_many :teams
  has_many :users, :through => :teams

  validates :name, :uniqueness => { :case_sensitive => false }
end
