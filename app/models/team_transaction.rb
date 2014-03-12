class TeamTransaction < ActiveRecord::Base
  include TeamTransactionHelper

  belongs_to :from_team, class_name: Team, foreign_key: :from_team_id
  belongs_to :to_team, class_name: Team, foreign_key: :to_team_id
  belongs_to :league
  belongs_to :activity_type
  belongs_to :nfl_player
  belongs_to :transaction_status

  scope :find_league_team, -> (l, t) {
    where('league_id = ? and (from_team_id = ? or to_team_id = ?)', l, t, t).order(:transaction_date)
  }

  after_save :try_set_league_week_data
  def try_set_league_week_data
    self.league.set_league_week_data
  end

  def self.get_latest_pick_time(league_id)
    TeamTransaction.where(league_id: league_id, from_team_id: 0, transaction_status_id:  1).maximum(:transaction_date)
  end

  def self.get_players_for_league_team(league_id, team_id, league_week = nil)
    players = Hash.new
    transactions = TeamTransaction.includes(:nfl_player).find_league_team(league_id, team_id)
    if league_week
      week = League.find_by(id: league_id).get_league_week_data_for_week(league_week)
      transactions = transactions.where("transaction_date < ?", week.end_date).order(:transaction_date, :id)
    end
    transactions = transactions.to_a

    transactions.each { |t|
      if(t.to_team_id == team_id)         # Add to array any players that went to the given team_id
        players[t.nfl_player_id] = t.nfl_player unless players.include?(t.nfl_player_id)
      elsif(t.from_team_id == team_id)    # Remove from the array any players that left from the given team_id
        players.delete t.nfl_player_id if players.include?(t.nfl_player_id)
      end
    }
    players.values
  end

  def self.get_players_taken(league_id, league_week = nil)
    players = []
    transactions = TeamTransaction.find_league_team(league_id, 0)

    if league_week
      week = League.find_by(id: league_id).get_league_week_data_for_week(league_week)
      transactions = transactions.where(transaction_status_id: 1).where("transaction_date < ?", week.end_date).order(:transaction_date, :id)
    end
    transactions = transactions.to_a

    transactions.each { |t|
      if(t.from_team_id == 0)             # Add to array any players that were taken from 0 (i.e. drafted from NFL pool)
        players.push t.nfl_player_id unless players.include?(t.nfl_player_id)
      elsif(t.to_team_id == 0)            # Remove from array any players that went to 0 (i.e. back to NFL pool)
        players.delete t.nfl_player_id if players.include?(t.nfl_player_id)
      end
    }
    players
  end
end
