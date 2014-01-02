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

    desc "Fill database with player game stats"
    task load_current_stats: :environment do
      puts 'Loading current NFL player game stats'
      loader = NflLoader.new
      loader.load_current_player_stats
    end

    desc "Fill database with player game stats"
    task load_all_stats: :environment do
      puts 'Loading all NFL player game stats'
      loader = NflLoader.new
      loader.load_all_player_stats
    end

    desc "Restore NFL data"
    task restore: :environment do
      Rake::Task['db:seed'].invoke
      Rake::Task['ff:nfl:load_teams'].invoke
      Rake::Task['ff:nfl:load_games'].invoke
      Rake::Task['ff:nfl:load_players'].invoke
      Rake::Task['ff:nfl:load_scores'].invoke
      Rake::Task['ff:nfl:load_current_stats'].invoke
    end
  end
end
