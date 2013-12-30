class PointsCalculator
  class PlayerGameData
    attr_accessor :player
    attr_accessor :game_player
    attr_accessor :game
    attr_accessor :game_stats
    attr_accessor :points
  end

  def initialize(league_id = nil)
    @league_id = league_id
    @rules = LeaguePointRule.where(league_id: league_id).to_ary
    @rules = LeaguePointRule.where(league_id: nil).to_ary unless @rules.count > 0
    @rules = @rules.keep_if { |r| r.multiplier > 0 || r.min_range > 0 || r.max_range > 0 }
  end

  def do_calculation(stats)
    points = 0.0

    @rules.each { |rule|
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
  private :do_calculation

  def calculate(game_id, player_id)
    game_player = NflGamePlayer.find_by(nfl_game_id: game_id, nfl_player_id: player_id)
    stats = NflGameStatMap.where(nfl_game_player_id: game_player.id).includes(:stat_type).to_ary
    do_calculation(stats)
  end

  def calculate_season(player_id, season = nil)
    all_stats = Array.new
    season = NflLoader.new.current_season unless season
    game_players = NflGamePlayer.includes(:player).joins(:season).where(nfl_seasons: { id: season.id }, nfl_player_id: player_id).to_ary
    stats = NflGameStatMap.includes(:stat_type, { :game => [:home_team, :away_team] }).where(nfl_game_player_id: game_players)
      .order('nfl_games.week').group_by{ |s| s.game }

    stats.each { |key, value|
      puts key.description
      data = PlayerGameData.new
      data.game_player = game_players.find(nfl_game_id: key.id).first
      data.player = data.game_player.player
      data.game = key
      data.game_stats = value
      data.points = do_calculation(value)
      all_stats.push(data)
    }
    all_stats
  end
end
