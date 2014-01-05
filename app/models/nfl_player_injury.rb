class NflPlayerInjury < ActiveRecord::Base
  belongs_to :player, class_name: NflPlayer, foreign_key: :nfl_player_id
end
