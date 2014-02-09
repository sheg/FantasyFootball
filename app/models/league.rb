class League < ActiveRecord::Base
  include LeaguesHelper

  belongs_to :league_type
  has_many :teams
  has_many :games
  has_many :users, :through => :teams
  has_many :payouts, class_name: LeaguePayout
  has_many :transactions, class_name: TeamTransaction

  validates :name, :uniqueness => { :case_sensitive => false }

  scope :full, -> { where('size = teams_count') }
  scope :open, -> { where('size != teams_count') }

  scope :all_leagues, -> { self.all.includes([:teams, :league_type]) }

  def user_part_of_league?(user)
    user.leagues.include?(self)
  end

  def total_weeks
    self.weeks + self.playoff_weeks
  end

  def get_nfl_week(league_week)
    nfl_week = self.nfl_start_week + league_week
    season_type_id = 1
    if(nfl_week > 17)
      season_type_id = 3
      nfl_week -= 17
    end

    { season_type_id: season_type_id, week: nfl_week }
  end

  def available_teams
    self.size - self.teams_count
  end

  def draft_transactions
    self.transactions.where(activity_type_id: ActivityType.DRAFT.id).order(:transaction_date)
  end
end