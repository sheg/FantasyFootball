class League < ActiveRecord::Base
  include LeaguesHelper

  has_one :league_type
  has_many :teams
  has_many :games
  has_many :users, :through => :teams
  has_many :payouts, class_name: LeaguePayout

  validates :name, :uniqueness => { :case_sensitive => false }

  scope :full, -> { where('size = teams_count') }
  scope :open, -> { where('size != teams_count') }

  def available_teams
    self.size - self.teams_count
  end
end