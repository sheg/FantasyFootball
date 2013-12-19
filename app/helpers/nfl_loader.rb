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

  def calculate_season_player_points(name)
    #teams need to be present in the db for this to work - run rake ff:nfl:load_teams to get them in there. bumblebeetuna.
    all_players = get_players.values.flatten
    player = all_players.find { |player| player['Name'].downcase == name.downcase }
    player_season_stats = player['PlayerSeason']
    field_goals = player_season_stats["FieldGoalsMade"]
    fumbles_lost = player_season_stats["FumblesLost"]
    two_point_conversion_passes = player_season_stats["TwoPointConversionPasses"]
    pass_ints = player_season_stats["PassingInterceptions"]
    passing_touchdowns = player_season_stats["PassingTouchdowns"]
    passing_yards = player_season_stats["PassingYards"]
    two_point_conversion_rec = player_season_stats["TwoPointConversionReceptions"]
    receiving_touchdowns = player_season_stats["ReceivingTouchdowns"]
    receiving_yards = player_season_stats["ReceivingYards"]
    two_point_conversion_runs = player_season_stats["TwoPointConversionRuns"]
    rushing_touchdowns = player_season_stats["RushingTouchdowns"]
    rushing_yards = player_season_stats["RushingYards"]
    extra_points = player_season_stats["ExtraPointsMade"]
    fumbles_recovered = player_season_stats["FumblesRecovered"]
    defensive_touchdowns = player_season_stats["DefensiveTouchdowns"]
    interceptions = player_season_stats["Interceptions"]
    sacks = player_season_stats["Sacks"]
    safeties = player_season_stats["Safeties"]

    total_score = (field_goals * 3) + (fumbles_lost * -2) + (two_point_conversion_passes * 2) + (pass_ints * -2) +
                  (passing_touchdowns * 6) + (passing_yards * 0.04) + (two_point_conversion_rec * 2) + (receiving_touchdowns * 6) +
                  (receiving_yards * 0.1) + (two_point_conversion_runs * 2) + (rushing_touchdowns * 6) + (rushing_yards * 0.1) +
                  (extra_points * 1) + (fumbles_recovered * 2) + (defensive_touchdowns * 6) + (interceptions * 2) + (sacks * 1) + (safeties * 2)


    #|      Stat Type               |     Api Key                     | Default Points |
    #| Field Goals                  | "FieldGoalsMade"                |       3        |
    #| Fumble lost                  | "FumblesLost"                   |       -2       |
    #| Passing Two point conversion | "TwoPointConversionPasses"      |       2        |
    #| Passing Interception         | "PassingInterceptions"          |       -2       |
    #| Passing Touchdowns           | "PassingTouchdowns"             |       6        |
    #| Passing Yards                | "PassingYards"                  |      .04       |
    #| Rec Two point conversion     | "TwoPointConversionReceptions"  |       2        |
    #| Receiving Touchdown          | "ReceivingTouchdowns"           |       6        |
    #| Receiving Yards              | "ReceivingYards"                |      .1        |
    #| Rush Two point conversion    | "TwoPointConversionRuns"        |       2        |
    #| Rushing Touchdowns           | "RushingTouchdowns"             |       6        |
    #| Rushing Yards                | "RushingYards"                  |      .1        |
    #| Extra Points                 | "ExtraPointsMade"               |       1        |
    #| Defensive Fumble Recoveries  | "FumblesRecovered"              |       2        |
    #| Defensive Touchdowns         | "DefensiveTouchdowns"           |       6        |
    #| Defensive Interceptions      | "Interceptions"                 |       2        |
    #| Defensive Sacks              | "Sacks"                         |       1        |
    #| Defensive Safeties           | "Safeties"                      |       2        |

  end
end