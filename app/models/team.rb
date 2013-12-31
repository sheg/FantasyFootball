class Team < ActiveRecord::Base
  belongs_to :league, :counter_cache => true
  belongs_to :user

  validates :user_id, :uniqueness => { scope: :league_id, message: "Cannot own more than one team per league" }
  validates :name, :uniqueness => { :case_sensitive => false }

  after_save :try_set_league_schedule

  def try_set_league_schedule
    self.league.set_schedule
  end
end