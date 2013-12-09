class TeamLoader

  $api_key = 'EE80A3DB-D928-4AFB-9931-57BB7B7892FE'
  $base_folder = File.join(Rails.root, 'lib', 'json_data')
  $my_folder = 'nfl'

  def load_json_data(url, cache_file)
    cache_fullpath = File.join($base_folder, $my_folder, cache_file)
    FileUtils.mkpath(File.dirname(cache_fullpath))

    if(File.exists?(cache_fullpath))
      puts "Using cache file #{cache_fullpath}"
      ret = JSON.parse(File.open(cache_fullpath).read)
    else
      puts "Pulling from API #{url}"
      json = load_from_api(url)

      if(json != nil)
        begin
          ret = JSON.parse(json)
        rescue
          # When json has been returned but cannot be parsed, it is a single value
          #   i.e. season is returned simply as "2013" so wrap it in mock JSON object
          ret = JSON.parse('{ "data": "' + json + '" }')
        end

        File.write(cache_fullpath, JSON.pretty_generate(ret)) if ret != nil
        puts "Saved cache file #{cache_fullpath}"
      else
        puts "No response from API"
      end
    end

    ret
  end

  def load_from_api(url)
    ret = nil

    require 'net/http'

    base_uri = 'http://api.nfldata.apiphany.com/trial/JSON/'
    uri = URI(base_uri + url)
    uri.query = URI.encode_www_form({ 'key' => $api_key })

    request = Net::HTTP::Get.new(uri.request_uri)

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    if(response.code == '200')
      ret = response.body
    end

    ret
  end

  def current_season
    data = load_json_data("CurrentSeason", "current_season.json")
    data["data"]
  end

  def load_teams
    season = current_season
    items = load_json_data("Teams/#{season}", "#{season}/teams.json")
    teams = items.map do |team|
      {
        name: team['FullName'],
        abbr: team['Key']
      }
    end

    teams.each do |team|
      NflTeam.create!(name: team[:name], abbr: team[:abbr])
    end
  end

  def load_players
    season = current_season
    NflTeam.all.each { |team|
      items = load_json_data("Players/#{team.abbr}", "#{season}/players/#{team.abbr}.json")
      puts "Players found: #{items.count}"
    }
  end
end
