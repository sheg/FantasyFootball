namespace :db do
  desc "Fill database with NFL Teams"
  task populate_teams: :environment do
    loader = TeamLoader.new
    loader.load_teams_via_fantasy_data
    loader.teams.each do |team|
      NflTeam.create!(name: team[:name], abbr: team[:abbr])
    end
  end
end