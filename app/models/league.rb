class League < ActiveRecord::Base
  include LeaguesHelper

  has_many :teams
  has_many :users, :through => :teams

  has_many :schedules
  has_many :games, through: :schedules

  validates :name, :uniqueness => { :case_sensitive => false }

  def available_teams
    self.size - self.teams_count
  end
end