class PointsCalculator
  class PlayerGameData
    attr_accessor :player
    attr_accessor :week
    attr_accessor :game_player
    attr_accessor :team
    attr_accessor :opponent
    attr_accessor :position
    attr_accessor :game
    attr_accessor :game_stats
    attr_accessor :current_points
    attr_accessor :last_points
    attr_accessor :total_points
    attr_accessor :average_points
    attr_accessor :league_points
    attr_accessor :started
    attr_accessor :is_home
    attr_accessor :bye

    def initialize
      self.current_points = 0.0
      self.last_points = 0.0
      self.total_points = 0.0
      self.average_points = 0.0

      self.started = false
    end

    def opponent_abbr
      abbr = 'N/A'
      abbr = (is_home ? '' : '@') + opponent.abbr if opponent
      abbr
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

  def do_calculation_db(season_type_id = nil, week = nil)
    puts "Calculating points data for SeasonTypeId #{season_type_id}, Week #{week}"

    sql = "CALL UpdateGamePlayerPoints(#{season_type_id}, #{week});"
    ActiveRecord::Base.connection.execute(sql)

    sql = "CALL LoadLeaguePlayerPoints(#{season_type_id}, #{week});"
    ActiveRecord::Base.connection.execute(sql)

    sql = "CALL UpdateTeamPoints(null, #{season_type_id}, #{week});"
    ActiveRecord::Base.connection.execute(sql)

    sql = "CALL PopulateTeamStandings();"
    ActiveRecord::Base.connection.execute(sql)
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
    groups = games.group_by{ |g| { season_type_id: g.season_type_id, week: g.week } }.keys
    groups.each { |group|
      do_calculation_db(group[:season_type_id], group[:week])
    }
    puts "Update Points for Games: DB Calculation Time taken: #{Time.now - start}"

    #game = games.first
    #
    #game_players = get_game_players(nil, game.season, game.season_type_id, game.week).to_a
    #puts "Game Players: #{game_players.count}"
    #
    #stats = get_stats(nil, game.season, game.season_type_id, game.week)
    #puts "Stats: #{stats.count}"
    #
    #puts "Update Points for Games: Loaded Stats Time taken: #{Time.now - start}"
    #
    #do_update(game_players, stats)
  end

  def update_game_player_points(player_id = nil, year = nil, season_type_id = nil, week = nil)
    start = Time.now
    do_calculation_db(season_type_id, week)
    puts "Update Points for Games: DB Calculation Time taken: #{Time.now - start}"
    return

    #start = Time.now
    #
    #season = year ? NflSeason.find_by(year: year) : NflLoader.new.current_season
    #season_type_id = 1 unless season_type_id
    #
    #game_players = get_game_players(player_id, season, season_type_id, week).to_a
    #stats = get_stats(player_id, season, season_type_id, week)
    #
    #puts "Update Points #{season.year}: Loaded Stats Time taken: #{Time.now - start}"
    #
    #do_update(game_players, stats)
  end

  def do_update(game_players, stats)
    start = Time.now
    leagues = League.all.to_a

    @league_points = []
    @final = []

    game_players.each { |game_player|
      value = stats[game_player.id]
      next unless value

      value = value.group_by{ |s| s.stat_type_id }

      game_player.points = do_calculation(value)

      if game_player.changed?
        puts "#{game_player.id} --- PlayerID #{game_player.nfl_player_id} --- Points #{game_player.points}"
        game_player.save
      end

      leagues.each { |league|
        league_point = LeaguePlayerPoint.new(league_id: league.id, player_id: game_player.nfl_player_id, nfl_week: game_player.game.week)
        league_point.stats = value

        10.times do
          @league_points.push league_point
        end

        #league_point = LeaguePlayerPoint.find_or_create_by!(league_id: league.id, player_id: game_player.nfl_player_id, nfl_week: game_player.game.week)
        #league_point.points = do_calculation(value)
        #league_point.save
      }
    }

    puts "Update Points: Calculation Time taken: #{Time.now - start}"
    start = Time.now

    puts @league_points.count

    while @league_points.count > 0
      item = @league_points.pop
      if item
        item.points = do_calculation(item.stats)
        #puts "League #{item.league_id}, Player #{item.player_id}, #{item.points}" if item.points > 0
        @final.push item
      end
    end

    puts "Update Points: League player points calculation Time taken: #{Time.now - start}"
    start = Time.now

    sql_array = Array.new

    if(@final.count > 0)
      weeks = @final.group_by{ |p| p.nfl_week }.keys

      sql_array.push "
          delete
          from league_player_points
          where nfl_week in (#{weeks.join(',')})
        "
    end

    statements = []
    while @final.size > 0 do
      items = @final.slice!(0, 100000)
      items.each { |item|
        statements.push "(#{item.league_id}, #{item.nfl_week}, #{item.player_id}, #{item.points})"
      }
      inserts = statements.join(",\n    ")
      sql_array.push "INSERT INTO league_player_points (league_id, nfl_week, player_id, points) VALUES #{inserts};"
    end

    sql_array.each { |sql|
      LeaguePlayerPoint.connection.execute(sql)
    }
    puts "Update Points: League player SQL Time taken: #{Time.now - start}"

    #threads = Array.new
    #for i in 1..10 do
    #  t = Thread.new {
    #    Thread.exclusive {
    #      NflSeasonTeamPlayer
    #      NflGameStatMap
    #    }
    #    while @league_points.count > 0
    #      item = @league_points.pop
    #      if item
    #        item.points = do_calculation(item.stats)
    #        #puts "League #{item.league_id}, Player #{item.player_id}, #{item.points}" if item.points > 0
    #      end
    #    end
    #  }
    #  threads.push t
    #end
    #threads.each do |thread|
    #  thread.join
    #end

    #raise "Junk"
  end
  private :do_update

  def get_nfl_player_game_data(players, year = nil, season_type_id = nil, week = nil)
    all_stats = Array.new

    season = year ? NflSeason.find_by(year: year) : NflLoader.new.current_season
    season_type_id = 1 unless season_type_id

    games = NflGame.where(season_id: season.id, season_type_id: season_type_id)
    games = games.where(week: week) if week
    weeks = games.select("distinct week").map { |g| g.week }.to_a

    #game_players = get_game_players(players, season, season_type_id, week).includes(:game, player: [ :news, :injuries, :teams, :positions ]).to_a
    game_players = get_game_players(players, season, season_type_id, week).includes(:game, :player, :team, :position).to_a
    stats = get_stats(players, season, season_type_id, week)

    player_hash = game_players.group_by{ |gp| [ gp.player, gp.game.week ] }

    byes = NflGame.where(season_id: season.id, away_team_id: 1).index_by { |g| g.home_team_id }

    all_points = NflGamePlayer.unscoped.joins(:game).where(nfl_player_id: players).where("nfl_games.season_id = ? and nfl_games.season_type_id = ?", season.id, season_type_id)
      .select("nfl_player_id, week, points").group_by { |gp| gp.nfl_player_id }

    weeks.each { |data_week|
      players.each { |player|
        data = PlayerGameData.new
        data.player = player
        data.week = data_week

        game_player = player_hash[ [player, data_week] ]
        if(game_player)
          data.game_player = game_player[0]
          data.game = data.game_player.game
          data.game_stats = stats[data.game_player.id]
          data.team = data.game_player.team
          data.position = data.game_player.position
          data.current_points = data.game_player.points
        else
          data.team = data.player.team_for_week(season_type_id, data_week)
          data.position = data.player.position_for_week(season_type_id, data_week)
          data.game = games.find { |g| g.week == data_week and (g.home_team_id == data.team.id or g.away_team_id == data.team.id) }
        end

        data.bye = byes[data.team.id].week
        data.is_home = (data.game.home_team_id == data.team.id)
        data.opponent = data.is_home ? data.game.away_team : data.game.home_team

        all_points_for_player = all_points[player.id]
        if all_points_for_player
          points_til_now = all_points_for_player.find_all { |gp| gp.week <= data_week }
          data.total_points = points_til_now.sum { |gp| gp.points }
          data.average_points = (data.total_points / points_til_now.count).round(2) if points_til_now.count > 0

          last_points = all_points[player.id].find { |gp| gp.week == data_week - 1 }
          data.last_points = last_points.points if last_points
        end

        all_stats.push(data)
      }
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
