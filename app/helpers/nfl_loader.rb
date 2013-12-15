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

  def convert_fantasy_data_time(epoch_time)
    time = epoch_time.match(/\d+/)[0]
    fail "Could not convert from epoch time" unless time
    Time.at(time.to_i / 1000)
  end
end
