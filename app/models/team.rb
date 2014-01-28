class Team < ActiveRecord::Base
  include TeamHelper

  belongs_to :league, :counter_cache => true
  belongs_to :user
  has_many :team_standings

  validates :user_id, :uniqueness => { scope: :league_id, message: "Cannot own more than one team per league" }
  validates :name, :uniqueness => { :case_sensitive => false }

  after_save :try_set_league_schedule

  def try_set_league_schedule
    self.league.set_schedule
    self.league.set_draft_order
  end

  def set_score_for_week(week, score)
    game = Game.find_by('(home_team_id = ? or away_team_id = ?) and week = ?', id, id, week)
    if game.home_team_id == id
      game.home_score = score
    else
      game.away_score = score
    end
    game.save
  end
end