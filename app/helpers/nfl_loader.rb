class NflLoader
  include ApiHelper
  set_my_folder('nfl')

  def current_season
    data = load_json_data('/CurrentSeason', 'current_season.json')
    season = NflSeason.find_or_create_by(year: data['data'])
  end

  def current_week
    data = load_json_data('/CurrentWeek', 'current_week.json')
    week = data['data']
  end

  def get_teams
    season = current_season.year
    items = load_json_data("/Teams/#{season}", "#{season}/teams.json")
    teams = items.map do |team|
      {
          name: team['FullName'],
          abbr: team['Key']
      }
    end

    teams
  end
  private :get_teams

  def load_teams
    NflTeam.find_or_create_by!(name: 'BYE', abbr: 'BYE') #needed for bye weeks

    teams = get_teams
    teams.each do |team|
      # Creates team as needed or updates existing if data has changed
      team = NflTeam.find_or_create_by!(abbr: team[:abbr])
      team.name = team[:name]
      team.save
    end
  end

  def get_players(season)
    hash = Hash.new
    NflTeam.where.not(abbr: 'BYE').each { |team|
      items = load_json_data("/Players/#{team.abbr}", "#{season.year}/players/#{team.abbr}.json", 86400)
      hash[team] = items
    }
    hash
  end
  private :get_players

  def load_players
    season = current_season
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
    position = NflPosition.find_or_create_by(abbr: item['FantasyPosition'])
    player = NflPlayer.find_or_create_by(external_player_id: item['PlayerID'])
    player.first_name = item['FirstName']
    player.last_name = item['LastName']
    player.photo_url = item['PhotoUrl']

    puts "NFL Player data updated ExternalID #{player.external_player_id}, #{player.full_name}" if player.changed?

    player.save

    team = NflTeam.find_by(abbr: item['Team']) unless team

    seasonEntry = NflSeasonTeamPlayer.find_or_create_by(season_id: season.id, team_id: team.id, player_id: player.id, position_id: position.id)
    # current_team_abbr: item['CurrentTeam'],
    seasonEntry.player_number = item['Number']

    puts "NFL SeasonTeamPlayer data updated #{player.full_name}, position #{position.abbr}, team #{team.abbr}" if seasonEntry.changed?

    seasonEntry.save

    player
  end
  private :create_player

  def get_games(season)
    items = load_json_data("/Schedules/#{season}", "#{season}/schedule.json")
    games = items.map do |game|
      game_time = convert_fantasy_data_time(game['Date'])
      {
          week: game['Week'],
          home_team: game['HomeTeam'],
          away_team: game['AwayTeam'],
          start_time: game_time,
          external_game_id: game['GameKey']
      }
    end
    games
  end
  private :get_games

  def load_games
    season = current_season
    games = get_games(season.year)

    games.each do |game|
      home_team = NflTeam.find_by(abbr: game[:home_team])
      away_team = NflTeam.find_by(abbr: game[:away_team])

      if(away_team.abbr == 'BYE')
        nfl_game = NflGame.find_or_create_by!(season_id: season.id, home_team_id: home_team.id)
      else
        nfl_game = NflGame.find_or_create_by!(external_game_id: game[:external_game_id])
      end

      nfl_game.week = game[:week]
      nfl_game.home_team_id = home_team.id
      nfl_game.away_team_id = away_team.id
      nfl_game.start_time = game[:start_time]

      puts "Game data updated ExternalID #{nfl_game.external_game_id}, Week #{nfl_game.week}, #{nfl_game.away_team.abbr} @#{nfl_game.home_team.abbr}" if nfl_game.changed?

      nfl_game.save
    end
  end

  def get_game_scores
    season = current_season.year
    # load_json_data("/Scores/#{season}", "#{season}/scores.json", 30)
    load_json_data("/Scores/#{season}", "#{season}/scores.json")
  end
  private :get_game_scores

  def load_game_scores
    games = get_game_scores
    games.each do |game|
      nfl_game = NflGame.find_by!(external_game_id: game["GameKey"])

      home_team = NflTeam.find_by(abbr: game["HomeTeam"])
      away_team = NflTeam.find_by(abbr: game["AwayTeam"])

      puts "Mismatched HomeTeam DB: #{nfl_game.home_team.abbr}, JSON: #{home_team.abbr}" if nfl_game.home_team.abbr != home_team.abbr
      puts "Mismatched AwayTeam DB: #{nfl_game.away_team.abbr}, JSON: #{away_team.abbr}" if nfl_game.home_team.abbr != home_team.abbr
      puts "Mismatched GameWeek DB: #{nfl_game.week}, JSON: #{game['Week']}" if nfl_game.week != game['Week']

      nfl_game.has_started = game["HasStarted"]
      nfl_game.has_started_q1 = game["Has1stQuarterStarted"]
      nfl_game.has_started_q2 = game["Has2ndQuarterStarted"]
      nfl_game.has_started_q3 = game["Has3rdQuarterStarted"]
      nfl_game.has_started_q4 = game["Has4thQuarterStarted"]
      nfl_game.is_over = game["IsOver"]
      nfl_game.is_in_progress = game["IsInProgress"]
      nfl_game.is_overtime = game["IsOvertime"]
      nfl_game.away_score = game["AwayScore"]
      nfl_game.away_score_q1 = game["AwayScoreQuarter1"]
      nfl_game.away_score_q2 = game["AwayScoreQuarter2"]
      nfl_game.away_score_q3 = game["AwayScoreQuarter3"]
      nfl_game.away_score_q4 = game["AwayScoreQuarter4"]
      nfl_game.away_score_ot = game["AwayScoreOvertime"]
      nfl_game.home_score = game["HomeScore"]
      nfl_game.home_score_q1 = game["HomeScoreQuarter1"]
      nfl_game.home_score_q2 = game["HomeScoreQuarter2"]
      nfl_game.home_score_q3 = game["HomeScoreQuarter3"]
      nfl_game.home_score_q4 = game["HomeScoreQuarter4"]
      nfl_game.home_score_ot = game["HomeScoreOvertime"]
      nfl_game.quarter = game["Quarter"]
      nfl_game.down = game["AwayScore"]
      nfl_game.yards_to_go = game["Distance"]
      nfl_game.yard_line = game["YardLine"]
      nfl_game.time_remaining = game["TimeRemaining"]
      nfl_game.field_side = (game["YardLineTerritory"] == nfl_game.home_team.abbr)
      nfl_game.possession = (game["Possession"] == nfl_game.home_team.abbr)

      puts "Game data updated ExternalID #{nfl_game.external_game_id}, Week #{nfl_game.week}, #{nfl_game.away_team.abbr} @#{nfl_game.home_team.abbr}" if nfl_game.changed?

      nfl_game.save
    end
  end

  def get_player_stats(season, week, cache_timeout = 0)
    load_json_data("/PlayerGameStatsByWeek/#{season}/#{week}", "#{season}/weeks/#{week}/stats.json", cache_timeout)
  end
  private :get_player_stats

  def load_player_stats(season, week, cache_timeout = 0)
    players = get_player_stats(season.year, week, cache_timeout)
    players.each do |item|
      player = NflPlayer.find_by(external_player_id: item['PlayerID'])
      unless player
        puts "Player not found in DB ExternalID: #{item['PlayerID']}, Team: #{item['Team']}, Name: #{item['Name']}... retrying"

        if(item['PlayerID'])
          player = load_player(season, item['PlayerID'])
          puts "Found player in DB ExternalID: #{player.external_player_id}, Name: #{player.full_name}" if player
        else
          team = NflTeam.find_by(abbr: item['Team'])
          team_player = NflSeasonTeamPlayer.find_by(season_id: season.id, team_id: team.id, player_number: item['Number'])
          if(team_player)
            player = NflPlayer.find_by(id: team_player.player_id)
            puts "Found player in DB ExternalID: #{player.external_player_id}, Name: #{player.full_name}, Number: #{team_player.player_number}" if player
          end
        end

        puts "Player not found in DB ExternalID: #{item['PlayerID']}, Team: #{item['Team']}, Name: #{item['Name']}" unless player
      end

      nfl_game = NflGame.find_by!(external_game_id: item['GameKey'])
      puts "Game not found in DB ExternalID: #{item['GameKey']}" unless nfl_game

      next unless player && nfl_game

      stat = NflGameStats.find_or_create_by!(nfl_game_id: nfl_game.id, nfl_player_id: player.id)
      stat.passing_yards = item['PassingYards']
      stat.interceptions = item['Interceptions']

      puts "Player stats updated #{player.full_name}, Game #{nfl_game.external_game_id}, Week #{nfl_game.week}, #{nfl_game.away_team.abbr} @#{nfl_game.home_team.abbr}" if stat.changed?

      stat.save
    end
  end
  private :load_player_stats

  def load_current_player_stats
    season = current_season
    week = current_week
    players = load_player_stats(season, week)
    # players = load_player_stats(season, week, 30)
  end

  def load_all_player_stats
    season = current_season
    week = current_week
    for i in 1..week.to_i
      players = load_player_stats(season, i)
    end
  end

  def convert_fantasy_data_time(epoch_time)
    time = epoch_time.match(/\d+/)[0]
    fail "Could not convert from epoch time" unless time
    Time.at(time.to_i / 1000)
  end
end
