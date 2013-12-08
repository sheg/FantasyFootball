namespace :db do
  desc "Fill database with NFL Teams"
  task populate_teams: :environment do
    loader = TeamLoader.new
    loader.load_teams_via_fantasy_data
    loader.teams.each do |team|
      NflTeam.create!(name: team[:name], abbr: team[:abbr])
    end
  end

  desc "Fill database with NFL Players"
  task populate_players: :environment do
    loader = TeamLoader.new
    loader.load_players_via_fantasy_data
    loader.players.each do |player|
      NflPlayer.create!(first_name: player[:first_name], last_name: player[:last_name])
    end
  end
end