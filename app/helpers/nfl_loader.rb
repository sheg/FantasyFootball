require 'thread'

class NflLoader
  include ApiHelper

  def initialize
    api_init
    set_my_folder('nfl')
  end

  def current_season
    data = load_json_data('/CurrentSeason', 'current_season.json', 86400)
    season = NflSeason.find_or_create_by(year: data['data'])
  end

  def current_week
    data = load_json_data('/CurrentWeek', 'current_week.json', 86400)
    week = data['data']
    week.to_i
  end

  def get_team(abbr)
    # Cache NFLTeams to minimize DB hits
    unless @nfl_teams
      Thread.exclusive {
        unless @nfl_teams
          @nfl_teams = Hash[NflTeam.all.map { |x| [x.abbr, x] }]
        end
      }
    end
    team = @nfl_teams[abbr]
    puts "Team not found in DB: #{abbr}" unless team
    team
  end

  def get_position(abbr)
    # Cache NFLPositions to minimize DB hits
    unless @nfl_positions
      Thread.exclusive {
        unless @nfl_positions
          @nfl_positions = Hash[NflPosition.all.map { |x| [x.abbr, x] }]
        end
      }
    end
    position = @nfl_positions[abbr]
    # puts "Position not found in DB: #{abbr}" unless position
    position
  end

  def get_stat_types
    # Cache StatTypes to minimize DB hits
    unless @stat_types
      Thread.exclusive {
        unless @stat_types
          @stat_types = StatType.all.to_ary
        end
      }
    end

    @stat_types
  end

  def get_weekly_data(api_method, cache_filename, season, week, season_type_id, cache_timeout = 0)
    season_type_name = NflSeason.get_season_type_name(season_type_id)
    api_season = "#{season}#{season_type_name}"
    cache_root_folder = season.to_s
    cache_root_folder += "/#{season_type_name}" if season_type_id.to_i > 1

    load_json_data("/#{api_method}/#{api_season}/#{week}", "#{cache_root_folder}/weeks/#{week}/#{cache_filename}", cache_timeout)
  end
  private :get_weekly_data

  def convert_fantasy_data_time(epoch_time)
    time = epoch_time.match(/\d+/)[0]
    fail "Could not convert from epoch time" unless time
    Time.at(time.to_i / 1000)
  end

  def load_all
    season = current_season
    week = current_week

    for i in 1..week.to_i
      players = load_items(season, i, 1)
    end

    # Load pre-season stats
    for i in 0..4
      players = load_items(season, i, 2)
    end
  end

  def load_current(cache_timeout = 0)
    season = current_season
    week = current_week
    load_items(season, week, 1, cache_timeout)
  end
end
