class TeamLoader

  attr_accessor :teams, :players

  def load_teams_via_fantasy_data
    api_data = JSON.parse(File.open(File.join(Rails.root, 'lib', 'teams.json')).read)
    @teams = api_data.map do |team|
      {
          name: team['FullName'],
          abbr: team['Key']
      }
    end
  end

  def new_function
    #nothing here as well whatever the hell
    #more things here because needed to fix as per requested
  end
end