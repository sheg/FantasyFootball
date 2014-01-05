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
      stat = stats[rule.stat_type_id]
      next unless stat

      stat = stat.first
      if stat and stat.value > 0
        match = true
        if (rule.min_range > 0 || rule.max_range > 0)
          match = false if stat.value < rule.min_range || stat.value > rule.max_range
        end

        next unless match

        # Use fixed points amount first, if not set then use multiplier
        calc = rule.fixed_points
        calc = (stat.value * rule.multiplier).round(4) unless calc > 0

        #puts "#{stat.stat_type.name}: fixed #{rule.fixed_points} || #{stat.value} * #{rule.multiplier} = #{calc}"

        points += calc
        points = points.round(4)
      end
    }
    BigDecimal(points.round(4), 4)
  end
  private :do_calculation

  def get_stats(game_players)
    stats = NflGameStatMap.includes(game: [:home_team, :away_team, :season])
      .where(nfl_game_player_id: game_players).where('value > 0')
      .order('nfl_games.week').group_by{ |s| s.game }
  end

  def update_game_player_points_for_games(game_ids)
    start = Time.now

    game_players = NflGamePlayer.unscoped.find_games(game_ids)
    game_players = game_players.readonly(false).to_a

    stats = NflGameStatMap.unscoped.find_games(game_ids)
    stats = stats.where('value > 0').to_a.group_by{ |s| s.nfl_game_player_id }

    puts "Update Points for Games: Loaded Stats Time taken: #{Time.now - start}"

    do_update(game_players, stats)
  end

  def update_game_player_points(player_id = nil, year = nil, week = nil)
    start = Time.now

    season = year ? NflSeason.find_by(year: year) : NflLoader.new.current_season

    game_players = NflGamePlayer.unscoped
    if week
      game_players = game_players.find_year_week(season.year, week)
    else
      game_players = game_players.find_year(season.year)
    end
    if player_id
      game_players = game_players.where(nfl_player_id: player_id)
    end
    game_players = game_players.readonly(false).to_a

    stats = NflGameStatMap.unscoped
    if week
      stats = stats.find_year_week(season.year, week)
    else
      stats = stats.find_year(season.year)
    end
    if player_id
      stats = stats.find_player(player_id)
    end
    stats = stats.where('value > 0').to_a.group_by{ |s| s.nfl_game_player_id }

    puts "Update Points #{season.year}: Loaded Stats Time taken: #{Time.now - start}"

    do_update(game_players, stats)
  end

  def do_update(game_players, stats)
    start = Time.now

    NflGamePlayer.transaction do
      game_players.each { |game_player|
        value = stats[game_player.id]
        next unless value

        value = value.group_by{ |s| s.stat_type_id }

        game_player.points = do_calculation(value)

        if game_player.changed?
          #puts "#{game_player.id} --- Points #{game_player.points}"
          game_player.save
        end
      }
    end

    puts "Update Points: Calculation Time taken: #{Time.now - start}"
  end
  private :do_update

  def get_player_game_data(player_id, year = nil, week = nil)
    all_stats = Array.new

    season = year ? NflSeason.find_by(year: year) : NflLoader.new.current_season

    game_players = NflGamePlayer.includes(player: [ :news, :injuries ]).joins(:season).where(nfl_seasons: { id: season.id }, nfl_player_id: player_id)
    game_players = game_players.includes(:game).where(nfl_games: { week: week }) if week
    game_players = game_players.to_ary

    #puts game_players.count

    stats = get_stats(game_players)

    stats.each { |key, value|
      value = value.group_by{ |s| s.stat_type_id }

      #puts key.description
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

  def test_threads
    results = Array.new
    threads = Array.new
    for i in 1..20 do
      t = Thread.new {
        Thread.exclusive {
          NflSeasonTeamPlayer
          NflGameStatMap
        }
        player_id = Thread.current.thread_variable_get(:player_id)
        results.push get_player_game_data(player_id, 2013).first
        ActiveRecord::Base.connection.close   # Release any DB connections used by the current thread
      }
      t.thread_variable_set(:player_id, i)
      threads.push t
    end
    threads.each do |thread|
      thread.join
    end

    10.times { puts '' }

    results.count
    #results
  end
end
