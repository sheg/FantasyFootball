class PointsCalculator
  class PlayerGameData
    attr_accessor :player
    attr_accessor :game_player
    attr_accessor :team
    attr_accessor :position
    attr_accessor :game
    attr_accessor :game_stats
    attr_accessor :points

    def initialize
      self.points = 0.0
    end

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

  def get_stats(player_id, season, season_type_id, week)
    stats = NflGameStatMap.unscoped
    if week
      stats = stats.find_year_week(season.year, season_type_id, week)
    else
      stats = stats.find_year(season.year, season_type_id)
    end
    if player_id
      stats = stats.find_player(player_id)
    end
    stats = stats.where('value > 0').to_a.group_by{ |s| s.nfl_game_player_id }
  end

  def get_game_players(player_id, season, season_type_id, week)
    game_players = NflGamePlayer.unscoped
    if week
      game_players = game_players.find_year_week(season.year, season_type_id, week)
    else
      game_players = game_players.find_year(season.year, season_type_id)
    end
    if player_id
      game_players = game_players.where(nfl_player_id: player_id)
    end
    game_players = game_players.includes(:game).readonly(false)
  end

  def update_game_player_points_for_games(games)
    return unless (games and games.length > 0)

    start = Time.now
    game = games.first

    game_players = get_game_players(nil, game.season, game.season_type_id, game.week).to_a
    puts "Game Players: #{game_players.count}"

    stats = get_stats(nil, game.season, game.season_type_id, game.week)
    puts "Stats: #{stats.count}"

    puts "Update Points for Games: Loaded Stats Time taken: #{Time.now - start}"

    do_update(game_players, stats)
  end

  def update_game_player_points(player_id = nil, year = nil, season_type_id = nil, week = nil)
    start = Time.now

    season = year ? NflSeason.find_by(year: year) : NflLoader.new.current_season
    season_type_id = 1 unless season_type_id

    game_players = get_game_players(player_id, season, season_type_id, week).to_a
    stats = get_stats(player_id, season, season_type_id, week)

    puts "Update Points #{season.year}: Loaded Stats Time taken: #{Time.now - start}"

    do_update(game_players, stats)
  end

  def do_update(game_players, stats)
    start = Time.now
    leagues = League.all.to_a

    game_players.each { |game_player|
      value = stats[game_player.id]
      next unless value

      value = value.group_by{ |s| s.stat_type_id }

      game_player.points = do_calculation(value)

      if game_player.changed?
        puts "#{game_player.id} --- PlayerID #{game_player.nfl_player_id} --- Points #{game_player.points}"
        game_player.save

        leagues.each { |league|
          #league_point = LeaguePlayerPoint.find_or_create_by!(league_id: league.id, player_id: game_player.nfl_player_id, nfl_week: game_player.game.week)
          #league_point.points = do_calculation(value)
          #league_point.save
          100.times do
            points = do_calculation(value)
          end
        }
      end
    }

    puts "Update Points: Calculation Time taken: #{Time.now - start}"
  end
  private :do_update

  def get_nfl_player_game_data(players, year = nil, season_type_id = nil, week = nil)
    all_stats = Array.new

    season = year ? NflSeason.find_by(year: year) : NflLoader.new.current_season
    season_type_id = 1 unless season_type_id

    #game_players = get_game_players(players, season, season_type_id, week).includes(:game, player: [ :news, :injuries, :teams, :positions ]).to_a
    game_players = get_game_players(players, season, season_type_id, week).includes(:game, :player).to_a
    stats = get_stats(players, season, season_type_id, week)

    player_hash = game_players.group_by{ |gp| gp.player }

    players.each { |player|
      data = PlayerGameData.new
      data.player = player

      game_player = player_hash[player]
      if(game_player)
        data.game_player = game_player[0]
        data.game = data.game_player.game
        data.game_stats = stats[data.game_player.id]
        data.team = data.game_player.team
        data.position = data.game_player.position
        data.points = data.game_player.points
      else
        data.team = data.player.team_for_week(season_type_id, week)
        data.position = data.player.position_for_week(season_type_id, week)
      end

      all_stats.push(data)
    }

    return all_stats
  end

  def get_nfl_game_data(game_id)
    game = NflGame.includes(:game_players, :season).find(game_id)
    return unless game

    player_ids = game.game_players.map{ |p| p.nfl_player_id }
    get_nfl_player_game_data(player_ids, game.season.year, game.season_type_id, game.week)
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
