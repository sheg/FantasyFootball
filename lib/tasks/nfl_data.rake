namespace :ff_db do
  desc "Fill database with NFL Teams"
  task populate_teams: :environment do
    loader = TeamLoader.new
    loader.load_teams
  end

  desc "Fill database with players"
  task populate_players: :environment do
    loader = TeamLoader.new
    loader.load_players
  end

end