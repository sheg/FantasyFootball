class PointsCalculator
  class PlayerGameData
    attr_accessor :player
    attr_accessor :game_player
    attr_accessor :game
    attr_accessor :game_stats
    attr_accessor :points

    def find_season_type(season_type_id)
      self.find { |d| d.game.season_type_id == season_type_id }
    end
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
        calc = (stat.value * rule.multiplier) unless calc > 0

        #puts "#{stat.stat_type.name}: fixed #{rule.fixed_points} || #{stat.value} * #{rule.multiplier} = #{calc}"

        points += calc
      end
    }
    BigDecimal(points.round(4), 12)
  end
  private :do_calculation

  def get_stats(player_id, season, week)
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
  end

  def get_game_players(player_id, season, week)
    game_players = NflGamePlayer.unscoped
    if week
      game_players = game_players.find_year_week(season.year, week)
    else
      game_players = game_players.find_year(season.year)
    end
    if player_id
      game_players = game_players.where(nfl_player_id: player_id)
    end
    game_players = game_players.readonly(false)
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

    game_players = get_game_players(player_id, season, week).to_a
    stats = get_stats(player_id, season, week)

    puts "Update Points #{season.year}: Loaded Stats Time taken: #{Time.now - start}"

    do_update(game_players, stats)
  end

  def do_update(game_players, stats)
    start = Time.now

    game_players.each { |game_player|
      value = stats[game_player.id]
      next unless value

      value = value.group_by{ |s| s.stat_type_id }

      game_player.points = do_calculation(value)

      if game_player.changed?
        puts "#{game_player.id} --- Points #{game_player.points}"
        game_player.save
      end
    }

    puts "Update Points: Calculation Time taken: #{Time.now - start}"
  end
  private :do_update

  def get_nfl_player_game_data(player_id, year = nil, week = nil)
    all_stats = Array.new

    season = year ? NflSeason.find_by(year: year) : NflLoader.new.current_season

    game_players = get_game_players(player_id, season, week).includes(:game, player: [ :news, :injuries ]).to_a

    games = Hash[game_players.map{|gp| [gp.game, gp]}]
    games = game_players.group_by{ |gp| gp.game }
    stats = get_game_players(player_id, season, week)

    games.each { |key, value|
      puts value.count
      data = PlayerGameData.new
      data.game_player = game_players.find{ |gp| gp.nfl_game_id == key.id }
      data.player = data.game_player.player
      data.game = key
      data.game_stats = value
      data.points = data.game_player.points
      all_stats.push(data)
    }

    all_stats
  end

  def get_nfl_team_game_data(team_id, year = nil, week = nil)
    all_stats = Array.new

    season = year ? NflSeason.find_by(year: year) : NflLoader.new.current_season

    game_players = get_game_players(player_id, season, week).includes(:game, player: [ :news, :injuries ]).to_a
    games = Hash[game_players.map{|gp| [gp.game, gp]}]
    stats = get_game_players(player_id, season, week)

    games.each { |key, value|
      data = PlayerGameData.new
      data.game_player = game_players.find{ |gp| gp.nfl_game_id == key.id }
      data.player = data.game_player.player
      data.game = key
      data.game_stats = value
      data.points = data.game_player.points
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
        results.push get_nfl_player_game_data(player_id, 2013).first
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
