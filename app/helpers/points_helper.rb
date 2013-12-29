module PointsHelper
  def self.calculate(game_id, player_id, league_id = nil)
    points = 0.0
    game_player = NflGamePlayer.find_by(nfl_game_id: game_id, nfl_player_id: player_id)

    stats = NflGameStatMap.where(nfl_game_player_id: game_player.id).includes(:stat_type).to_ary

    rules = LeaguePointRule.where(league_id: league_id).to_ary
    rules = LeaguePointRule.where(league_id: nil).to_ary unless rules.count > 0
    rules = rules.keep_if { |r| r.multiplier > 0 || r.min_range > 0 || r.max_range > 0 }

    rules.each { |rule|
      stat = stats.find { |item| item.stat_type_id == rule.stat_type_id }
      if stat and stat.value > 0
        match = true
        if (rule.min_range > 0 || rule.max_range > 0)
          match = false if stat.value < rule.min_range || stat.value > rule.max_range
        end

        next unless match

        # Use fixed points amount first, if not set then use multiplier
        calc = rule.fixed_points
        calc = (stat.value * rule.multiplier).round(4) unless calc > 0

        puts "#{stat.stat_type.name}: fixed #{rule.fixed_points} || #{stat.value} * #{rule.multiplier} = #{calc}"

        points += calc
        points = points.round(4)
      end
    }
    points
  end
end
