module Loaders
  class NflPlayerLoader < NflLoader
    def get_nfl_game(external_game_id)
      # Cache NFLGames to minimize DB hits
      nfl_game = @nfl_games[external_game_id]
      unless(nfl_game)
        Thread.exclusive {
          nfl_game = @nfl_games[external_game_id]
          unless(nfl_game)
            nfl_game = NflGame.find_by!(external_game_id: external_game_id)
            @nfl_games[external_game_id] = nfl_game
          end
        }
      end
      puts "Game not found in DB ExternalID: #{external_game_id}" unless nfl_game
      nfl_game
    end

    def create_defense_players(season)
      NflTeam.where.not(abbr: 'BYE').each do |team|
        position = NflPosition.find_or_create_by(abbr: 'DST')
        player = NflPlayer.find_or_create_by(external_player_id: "DST_#{team.abbr}")
        player.first_name = team.name
        player.last_name = 'Defense'

        puts "NFL Player data updated ExternalID #{player.external_player_id}, #{player.full_name}" if player.changed?

        player.save

        seasonEntry = NflSeasonTeamPlayer.find_or_create_by(season_id: season.id, team_id: team.id, player_id: player.id, position_id: position.id)
        seasonEntry.player_number = 0

        puts "NFL SeasonTeamPlayer data updated #{player.full_name}, position #{position.abbr}, team #{team.abbr}" if seasonEntry.changed?

        seasonEntry.save
      end
    end

    def get_players(season)
      hash = Hash.new
      NflTeam.where.not(abbr: 'BYE').each { |team|
        #items = load_json_data("/Players/#{team.abbr}", "#{season.year}/players/#{team.abbr}.json", 86400)
        items = load_json_data("/Players/#{team.abbr}", "#{season.year}/players/#{team.abbr}.json", 0)
        items = [] unless items
        hash[team] = items
      }
      hash
    end
    private :get_players

    def load_players
      season = current_season

      create_defense_players(season)

      playersHash = get_players(season)
      playersHash.each { |team, playersData|
        puts "#{team.abbr} playersData: #{playersData.count}"

        players = Array.new
        playersData.each { |item|
          player = create_player(item, season, team)
          players.push(player)
        }

        puts "Positions: #{NflPosition.count}, NflSeasonTeamPlayer: #{NflSeasonTeamPlayer.where(team_id: team.id).count}"
      }
    end

    def load_player(season, external_player_id)
      item = load_json_data("/Player/#{external_player_id}", "#{season.year}/players/lookup/#{external_player_id}.json")
      create_player(item, season)
    end
    private :load_player

    def create_player(item, season, team = nil)
      return unless item

      position = get_position(item['FantasyPosition'])
      return unless position

      player = NflPlayer.find_or_create_by(external_player_id: item['PlayerID'])
      player.first_name = item['FirstName']
      player.last_name = item['LastName']
      player.photo_url = item['PhotoUrl']

      puts "NFL Player data updated ExternalID #{player.external_player_id}, #{player.full_name}" if player.changed?

      player.save

      item['LatestNews'].each { |news_data|
        news = NflPlayerNews.find_or_create_by(nfl_player_id: player.id, external_news_id: news_data['NewsID'])
        news.headline = news_data['Title']
        news.body = news_data['Content']
        news.source = news_data['Source']
        news.url = news_data['Url']
        news.terms = news_data['TermsOfUse']
        news.news_date = convert_fantasy_data_time(news_data['Updated'])

        puts "NFL Player News updated #{player.full_name}, ExternalID #{news.external_news_id}, #{news.headline}" if news.changed?

        news.save
      }

      team = get_team(item['Team']) unless team

      seasonEntry = NflSeasonTeamPlayer.find_or_create_by(season_id: season.id, team_id: team.id, player_id: player.id, position_id: position.id)
      seasonEntry.player_number = item['Number']

      puts "NFL SeasonTeamPlayer data updated #{player.full_name}, position #{position.abbr}, team #{team.abbr}" if seasonEntry.changed?

      seasonEntry.save

      player
    end
    private :create_player

    def get_items(season, week, season_type_id, cache_timeout = 0)
      #items = get_weekly_data('PlayerGameStatsByWeek', 'stats.json', season, week, season_type_id, cache_timeout)
      #puts items.count
      #return items

      teams = NflTeam.where.not(abbr: 'BYE').to_a
      items = []

      threads = Array.new
      for i in 1..20
        t = Thread.new {
          while teams.count > 0 do
            team = nil
            Thread.exclusive {
              NflSeasonTeamPlayer; NflPlayer;
              team = teams.pop if teams.count > 0
            }
            break unless team

            loaded = get_weekly_data('PlayerGameStatsByTeam', "stats/#{team.abbr}.json", season, week, season_type_id, cache_timeout, team.abbr)
            items += loaded
          end
        }
        t["name"] = i
        threads.push(t)
      end

      threads.each do |t|
        t.join
      end

      return items
    end
    private :get_items

    def load_items(season, week, season_type_id, cache_timeout = 0)
      NflGamePlayer.transaction do
        begin
          do_load_items(season, week, season_type_id, cache_timeout)
        rescue Exception => e
          puts e.message[0,400]
          puts e.backtrace.join("\n   ")
          raise ActiveRecord::Rollback
        end
      end
    end

    def do_load_items(season, week, season_type_id, cache_timeout = 0)
      get_start = Time.now
      items = get_items(season.year, week, season_type_id, cache_timeout)
      puts "Week #{week}: API+JSON loading time taken: #{Time.now - get_start}"

      @process_players = nil
      @nfl_games = Hash.new
      @player_stat_sql = Array.new

      get_start = Time.now

      # Since we are in a big transaction, threads do not work properly... the game player data does not show up within
      #   the scope of the running transaction so for now cannot use threading here
      #threads = Array.new
      #for i in 1..3
      #  t = Thread.new { thread_process_player_stats(season, items) }
      #  t["name"] = i
      #  threads.push(t)
      #end
      #
      #threads.each do |t|
      #  t.join
      #end

      thread_process_player_stats(season, items)

      puts "Week #{week}: player processing time taken: #{Time.now - get_start}"

      load_defense_stats(season, week, season_type_id, cache_timeout)

      sql_array = Array.new

      if(@nfl_games.count > 0)
        game_ids = @nfl_games.values.map { |v| v.id }.join(',')
        sql_array.push "
          delete
          from nfl_game_stat_maps
          where nfl_game_player_id in (
            select gp.id
            from nfl_game_players gp
              inner join nfl_games g on gp.nfl_game_id = g.id
            where g.id in (#{game_ids})
          )
        "
      end

      while @player_stat_sql.size > 0 do
        statements = @player_stat_sql.slice!(0, 100000)
        inserts = statements.join(",\n    ")
        sql_array.push "INSERT INTO nfl_game_stat_maps (nfl_game_player_id, stat_type_id, value) VALUES #{inserts};"
      end

      get_start = Time.now
      sql_array.each { |sql|
        NflGameStatMap.connection.execute(sql)
      }
      puts "Week #{week}: stat SQL time taken: #{Time.now - get_start}"

      PointsCalculator.new.update_game_player_points_for_games(@nfl_games.values)
    end
    private :load_items

    def thread_process_player_stats(season, items)
      Thread.exclusive {
        # Gets around issue error in autoload activerecord objects
        NflSeasonTeamPlayer
        NflPlayer

        unless @process_players
          ids = items.map{ |item| item['PlayerID'].to_s }
          @process_players = Hash[NflPlayer.where(external_player_id: ids).map{ |p| [p.external_player_id, p]}]
        end
      }

      while items.count > 0
        item = nil
        Thread.exclusive {
          item = items.pop
        }
        player = process_player_stats(season, item) if item
      end

      ActiveRecord::Base.connection.close   # Release any DB connections used by the current thread
    end
    private :thread_process_player_stats

    def process_player_stats(season, item)
      position = get_position(item['FantasyPosition'])
      return unless position

      #player = NflPlayer.find_by(external_player_id: item['PlayerID'])
      player = @process_players[item['PlayerID'].to_s]
      unless player
        puts "Player not found in DB ExternalID: #{item['PlayerID']}, Team: #{item['Team']}, Name: #{item['Name']}... retrying"

        if(item['PlayerID'])
          player = load_player(season, item['PlayerID'])
          puts "Found player in DB ExternalID: #{player.external_player_id}, Name: #{player.full_name}" if player
        else
          team = get_team(item['Team'])
          team_player = NflSeasonTeamPlayer.find_by(season_id: season.id, team_id: team.id, player_number: item['Number'])
          if(team_player)
            player = NflPlayer.find_by(id: team_player.player_id)
            puts "Found player in DB ExternalID: #{player.external_player_id}, Name: #{player.full_name}, Number: #{team_player.player_number}" if player
          end
        end

        puts "Player not found in DB ExternalID: #{item['PlayerID']}, Team: #{item['Team']}, Name: #{item['Name']}" unless player
      end
      return unless player

      nfl_game = get_nfl_game(item['GameKey'])
      return unless nfl_game

      team = get_team(item['Team'])
      return unless team

      game_player = update_game_player(nfl_game, player, team, position)

      stat_types = get_stat_types

      stat_types.each { |stat_type|
        next unless (item[stat_type.name] and item[stat_type.name].to_d > 0)
        @player_stat_sql.push "(#{game_player.id}, #{stat_type.id}, #{item[stat_type.name]})"
      }

      player
    end
    private :process_player_stats

    def update_game_player(nfl_game, player, team, position)
      game_player = NflGamePlayer.find_or_create_by(nfl_game_id: nfl_game.id, nfl_player_id: player.id)
      game_player.nfl_team_id = team.id
      game_player.nfl_position_id = position.id

      puts "GamePlayer data updated ExternalID #{nfl_game.external_game_id}, Player #{player.full_name}, Team #{team.abbr}, Position #{position.abbr}" if game_player.changed?

      game_player.save
      game_player
    end

    def get_defense_stats(season, week, season_type_id, cache_timeout = 0)
      #get_weekly_data('FantasyDefenseByGame', 'stats_defense.json', season, week, season_type_id, cache_timeout)
      get_weekly_data('TeamGameStats', 'team_game_stats.json', season, week, season_type_id, cache_timeout)
    end
    private :get_defense_stats

    def load_defense_stats(season, week, season_type_id, cache_timeout)
      year = season.year
      items = get_defense_stats(year, week, season_type_id, cache_timeout)
      stat_types = get_stat_types

      items.each do |item|
        player = NflPlayer.find_by!(external_player_id: "DST_#{item['Team']}")
        nfl_game = get_nfl_game(item['GameKey'])
        next unless nfl_game

        team = get_team(item['Team'])
        position = get_position('DST')

        game_player = update_game_player(nfl_game, player, team, position)

        stat_types.each { |stat_type|
          next unless (item[stat_type.name] and item[stat_type.name].to_d > 0)
          @player_stat_sql.push "(#{game_player.id}, #{stat_type.id}, #{item[stat_type.name]})"
        }
      end
    end
    private :load_defense_stats

    def load_current
      super(30)
      #load_current_player_stats_thread_test
    end

    def load_current_player_stats_thread_test
      season = current_season
      week = current_week
      season_type_id = 1

      if(week > 17)
        week -= 17
        season_type_id = 3
      end

      game = NflGame.where(season_id: season.id, season_type_id: season_type_id, week: week).order(:start_time).first
      test = NflGameStatMap.includes(:game).where(nfl_games: { id: game.id }).order(:nfl_game_player_id).first
      if test
        test.value = 666
        test.save

        game_player = NflGamePlayer.find_by(id: test.nfl_game_player_id)
        game_player.points = -1
        game_player.save
      end

      t1 = Thread.new { load_items(season, week, season_type_id) }

      if test
        threads = Array.new
        for i in 1..3 do
          threads.push Thread.new {
            Thread.exclusive {
              NflSeasonTeamPlayer
              NflGameStatMap
            }

            for i in 1..10 do
              test = NflGameStatMap.includes(:game).where(nfl_games: { id: game.id }).order(:nfl_game_player_id).first
              game_player = NflGamePlayer.find_by(id: test.nfl_game_player_id)
              puts test.inspect
              puts game_player.inspect
              sleep(0.3)
            end
          }
        end
        threads.each do |thread|
          thread.join
        end
      end

      t1.join
    end
  end
end
