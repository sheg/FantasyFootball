namespace :ff do
  namespace :nfl do
    desc "Fill database with NFL Teams"
    task load_teams: :environment do
      puts 'Loading NflTeams'
      Loaders::NflTeamLoader.new.load_teams
    end

    #desc "Fill database with NFL games"
    #task load_games: :environment do
    #  puts 'Loading NflGames'
    #  Loaders::NflGameLoader.new.load_game_scores
    #end

    desc "Fill database with game scores"
    task load_scores: :environment do
      puts 'Loading NFL game scores'
      Loaders::NflGameLoader.new.load_current
    end

    desc "Fill database with players"
    task load_players: :environment do
      puts 'Loading NflPlayers'
      Loaders::NflPlayerLoader.new.load_players
    end

    desc "Load current week player stats"
    task load_current_stats: :environment do
      puts 'Loading current week player stats'
      Loaders::NflPlayerLoader.new.load_current
    end

    desc "Load all player stats"
    task load_all_stats: :environment do
      puts 'Loading all player stats'
      Loaders::NflPlayerLoader.new.load_all
    end

    desc "Load current week player injuries"
    task load_current_injuries: :environment do
      puts 'Loading current week injuries'
      Loaders::NflInjuriesLoader.new.load_current
    end

    desc "Load all  player injuries"
    task load_all_injuries: :environment do
      puts 'Loading all injuries'
      Loaders::NflInjuriesLoader.new.load_all
    end

    desc "Restore NFL data"
    task restore: :environment do
      Rake::Task['db:seed'].invoke
      Rake::Task['ff:nfl:load_teams'].invoke
      #Rake::Task['ff:nfl:load_games'].invoke
      Rake::Task['ff:nfl:load_scores'].invoke
      Rake::Task['ff:nfl:load_players'].invoke
      Rake::Task['ff:nfl:load_current_injuries'].invoke
      Rake::Task['ff:nfl:load_current_stats'].invoke
    end

    desc "Restore NFL data"
    task update: :environment do
      Rake::Task['ff:nfl:load_scores'].invoke
      Rake::Task['ff:nfl:load_current_stats'].invoke

      #t1 = Thread.new {
      #  Thread.exclusive { Loaders::NflGameLoader; NflSeasonTeamPlayer; NflGameStatMap; }
      #  Rake::Task['ff:nfl:load_scores'].invoke
      #}
      #t2 = Thread.new {
      #  Thread.exclusive { Loaders::NflPlayerLoader; NflSeasonTeamPlayer; NflGameStatMap; }
      #  Rake::Task['ff:nfl:load_current_stats'].invoke
      #}
      #
      #t1.join
      #t2.join
    end
  end
end
