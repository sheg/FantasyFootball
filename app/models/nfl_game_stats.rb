class NflGameStats < ActiveRecord::Base
  belongs_to :game, class_name: NflGame, foreign_key: :nfl_game_id
  belongs_to :player, class_name: NflPlayer, foreign_key: :nfl_player_id

  scope :for_week, ->(w) { includes(:game).where('nfl_games.week = ?', w).references(:nfl_games) }
end
