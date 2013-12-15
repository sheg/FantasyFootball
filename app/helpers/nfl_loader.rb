class NflLoader
  include ApiHelper
  set_my_folder('nfl')

  def current_season
    data = load_json_data('/CurrentSeason', 'current_season.json')
    season = NflSeason.find_or_create_by(year: data['data'])
    season
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
      items = load_json_data("/Players/#{team.abbr}", "#{season.year}/players/#{team.abbr}.json")
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
        position = NflPosition.find_or_create_by(abbr: item['FantasyPosition'])
        player = NflPlayer.find_or_create_by(external_player_id: item['PlayerID'])
        player.first_name = item['FirstName']
        player.last_name = item['LastName']
        player.photo_url = item['PhotoUrl']
        player.save
        players.push(player)

        seasonEntry = NflSeasonTeamPlayer.find_or_create_by(season_id: season.id, team_id: team.id, player_id: player.id, position_id: position.id)
        # current_team_abbr: item['CurrentTeam'],
        seasonEntry.player_number = item['Number']
        seasonEntry.save
      }

      puts "Positions: #{NflPosition.count}, NflSeasonTeamPlayer: #{NflSeasonTeamPlayer.where(team_id: team.id).count}"
    }
  end

  def get_games
    season = current_season.year
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
    games = get_games

    games.each do |game|
      home_team = NflTeam.find_by(abbr: game[:home_team])
      away_team = NflTeam.find_by(abbr: game[:away_team])

      nfl_game = NflGame.find_or_create_by!(external_game_id: game[:external_game_id])
      nfl_game.week = game[:week]
      nfl_game.home_team_id = home_team.id
      nfl_game.away_team_id = away_team.id
      nfl_game.start_time = game[:start_time]
      nfl_game.save
    end
  end

  def get_game_scores
    season = current_season.year
    items = load_json_data("/Scores/#{season}", "#{season}/scores.json", 30)
    items
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

  def convert_fantasy_data_time(epoch_time)
    time = epoch_time.match(/\d+/)[0]
    fail "Could not convert from epoch time" unless time
    Time.at(time.to_i / 1000)
  end
end
