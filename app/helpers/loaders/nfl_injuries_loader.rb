module Loaders
  class NflInjuriesLoader < NflLoader
    def get_items(season, week, season_type_id, cache_timeout = 0)
      get_weekly_data('Injuries', 'injuries.json', season, week, season_type_id, cache_timeout)
    end
    private :get_items

    def load_items(season, week, season_type_id, cache_timeout = 0)
      get_start = Time.now

      year = season.year
      items = get_items(year, week, season_type_id, cache_timeout)

      threads = Array.new
      for i in 1..3
        t = Thread.new { thread_process_injuries(season, items) }
        t["name"] = i
        threads.push(t)
      end

      threads.each do |t|
        t.join
      end

      puts "Injuries: Week #{week}: loading time taken: #{Time.now - get_start}"
    end

    def thread_process_injuries(season, array)
      Thread.exclusive {
        # Gets around issue error in autoload activerecord objects
        NflSeasonTeamPlayer
        NflPlayer
      }

      while array.count > 0
        item = nil
        Thread.exclusive {
          item = array.pop
        }
        process_injury(season, item) if item
      end

      ActiveRecord::Base.connection.close   # Release any DB connections used by the current thread
    end
    private :thread_process_injuries

    def process_injury(season, item)
      player = NflPlayer.find_by(external_player_id: item['PlayerID'])
      return unless player

      injury = NflPlayerInjury.find_or_create_by(nfl_player_id: player.id, external_injury_id: item['InjuryID'])
      injury.injury_date = convert_fantasy_data_time(item['Updated'])
      injury.body_part = item['BodyPart']
      injury.practice = item['Practice']
      injury.practice_description = item['PracticeDescription']
      injury.status = item['Status']
      injury.week = item['Week']
      injury.season_id = season.id
      injury.season_type_id = item['SeasonType']

      puts "NFL Player Injury updated #{player.full_name}, ExternalID #{injury.external_injury_id}, #{injury.body_part}, #{injury.status}" if injury.changed?

      injury.save
    end

    def load_current
      super(3600)
    end
  end
end
