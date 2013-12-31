class League < ActiveRecord::Base
  include LeaguesHelper

  has_many :teams
  has_many :games
  has_many :users, :through => :teams

  validates :name, :uniqueness => { :case_sensitive => false }
  #scope :rotting, -> { where(rotting: true) }

  scope :full, -> { where('size = teams_count') }
  scope :open, -> { where('size != teams_count') }

  def available_teams
    self.size - self.teams_count
  end
end