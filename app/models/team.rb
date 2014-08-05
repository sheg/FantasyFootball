class Team < ActiveRecord::Base
  include TeamHelper

  belongs_to :league, :counter_cache => true
  belongs_to :user
  has_many :team_standings

  validates :user_id, :uniqueness => { scope: :league_id, message: "Cannot own more than one team per league" }
  validates :name, :uniqueness => { :case_sensitive => false }

  after_save :try_set_league_schedule
  after_destroy :remove_games

  def try_set_league_schedule
    self.league.set_schedule
    self.league.set_draft_order
  end

  def remove_games
    games = Game.where('league_id = ?', self.league_id)
    games.destroy_all
  end
end