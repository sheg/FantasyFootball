class TeamLoader

  attr_accessor :teams, :players

  $base_folder = File.join(Rails.root, 'lib', 'json_data')
  $my_folder = 'nfl'

  def load_teams_via_fantasy_data
    api_data = JSON.parse(File.open(File.join($base_folder, $my_folder, 'teams.json')).read)
    @teams = api_data.map do |team|
      {
          name: team['FullName'],
          abbr: team['Key']
      }
    end
  end
end
