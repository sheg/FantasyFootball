module Loaders
  class NflTeamLoader < NflLoader
    def get_teams
      season = current_season.year
      items = load_json_data("/Teams/#{season}", "#{season}/teams.json", 86400)
    end
    private :get_teams

    def load_teams
      NflTeam.find_or_create_by!(name: 'BYE', abbr: 'BYE') #needed for bye weeks

      items = get_teams
      items.each do |item|
        # Creates team as needed or updates existing if data has changed
        team = NflTeam.find_or_create_by!(abbr: item['Key'])
        team.name = item['FullName']
        team.save
      end
    end
  end
end
