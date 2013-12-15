namespace :ff do
  namespace :nfl do
    desc "Fill database with NFL Teams"
    task load_teams: :environment do
      puts 'Loading NflTeams'
      loader = NflLoader.new
      loader.load_teams
    end

    desc "Fill database with NFL games"
    task load_games: :environment do
      puts 'Loading NflGames'
      loader = NflLoader.new
      loader.load_games
    end

    desc "Fill database with players"
    task load_players: :environment do
      puts 'Loading NflPlayers'
      loader = NflLoader.new
      loader.load_players
    end

    desc "Fill database with game scores"
    task load_scores: :environment do
      puts 'Loading NFL game scores'
      loader = NflLoader.new
      loader.load_game_scores
    end

    desc "Restore NFL data"
    task restore: :environment do
      Rake::Task['ff:nfl:load_teams'].invoke
      Rake::Task['ff:nfl:load_games'].invoke
      Rake::Task['ff:nfl:load_players'].invoke
      Rake::Task['ff:nfl:load_game_scores'].invoke
    end
  end
end
