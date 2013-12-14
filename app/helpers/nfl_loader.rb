class NflLoader
  include ApiHelper
  set_my_folder('nfl')

  def current_season
    data = load_json_data('/CurrentSeason', 'current_season.json')
    data['data']
  end

  def get_teams
    season = current_season
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
      NflTeam.create!(name: team[:name], abbr: team[:abbr])
    end
  end

  def get_players
    players = Hash.new
    season = current_season
    NflTeam.all.each { |team|
      items = load_json_data("/Players/#{team.abbr}", "#{season}/players/#{team.abbr}.json")
      players[team.abbr] = items
    }
    players
  end
  private :get_players

  def load_players
    players = get_players
    players.each { |team, players|
      puts "#{team} players: #{players.count}"
    }
  end

  def get_games
    season = current_season
    items = load_json_data("/Schedules/#{season}", "#{season}/schedule.json")
    games = items.map do |game|
      game_time = convert_fantasy_data_time(game['Date'])
      {
          week: game['Week'],
          home_team: game['HomeTeam'],
          away_team: game['AwayTeam'],
          start_time: game_time
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
      NflGame.create!(
          week: game[:week],
          home_team: home_team,
          away_team: away_team,
          start_time: game[:start_time]
      )
    end
  end

  def convert_fantasy_data_time(epoch_time)
    time = epoch_time.match(/\d+/)[0]
    fail "Could not convert from epoch time" unless time
    Time.at(time.to_i / 1000)
  end
end
