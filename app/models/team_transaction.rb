class TeamTransaction < ActiveRecord::Base
  include TeamTransactionHelper

  belongs_to :from_team, class_name: Team, foreign_key: :from_team_id
  belongs_to :to_team, class_name: Team, foreign_key: :to_team_id
  belongs_to :league
  belongs_to :activity_type
  belongs_to :nfl_player

  scope :find_league_team, -> (l, t) {
    where('league_id = ? and (from_team_id = ? or to_team_id = ?)', l, t, t).order(:transaction_date)
  }

  def self.get_latest_pick_time(league_id)
    TeamTransaction.where(league_id: league_id, from_team_id: 0).maximum(:transaction_date)
  end

  def self.get_player_ids_for_league_team(league_id, team_id)
    players = []
    transactions = TeamTransaction.find_league_team(league_id, team_id).to_a
    transactions.each { |t|
      if(t.to_team_id == team_id)         # Add to array any players that went to the given team_id
        players.push t.nfl_player_id unless players.include?(t.nfl_player_id)
      elsif(t.from_team_id == team_id)    # Remove from the array any players that left from the given team_id
        players.delete t.nfl_player_id if players.include?(t.nfl_player_id)
      end
    }
    players
  end

  def self.get_players_taken(league_id)
    players = []
    transactions = TeamTransaction.find_league_team(league_id, 0).to_a
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
