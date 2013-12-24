module PointsHelper
  def self.calculate(game_id, player_id, league_id = nil)
    points = 0.0
    stats = NflGameStatMap.where(nfl_game_id: game_id, nfl_player_id: player_id).includes(:stat_type).to_ary

    rules = LeaguePointRule.where(league_id: league_id)
    rules.each { |rule|
      stat = stats.find { |item| item.stat_type_id == rule.stat_type_id }
      if stat
        calc = (stat.value * rule.multiplier).round(4)
        puts "#{stat.stat_type.name}: #{stat.value} * #{rule.multiplier} = #{calc}" if stat.value > 0 and rule.multiplier > 0

        points += calc
        points = points.round(4)
      end
    }
    points
  end
end
