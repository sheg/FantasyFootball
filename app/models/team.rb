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

  def set_score_for_week(week, score)
    game = Game.find_by('(home_team_id = ? or away_team_id = ?) and week = ?', self.id, self.id, week)
    if game.home_team_id == self.id
      game.home_score = score
    else
      game.away_score = score
    end
    game.save
  end

  def remove_games

    #See league.set_schedule - last filled user leaves, then rejoins. Gotta wipe games so we can re-recreate the schedule for the new guy.

    games = Game.where('league_id = ?', self.league_id)
    games.destroy_all
  end
end