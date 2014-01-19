namespace :ff do
  namespace :data do
    desc "Fill database with 10 fake leagues"
    task populate_leagues: :environment do
      3.times { League.new.create_test_league }
      3.times { League.new.create_test_league(0, 3)}
    end

    desc "Add random scores to first 8 games"
    task populate_game_scores: :environment do
      for week_index in 1..8 do
        games_in_week = Game.where(week: week_index)
        games_in_week.each do |game|
          game.update(home_score: Random.rand(150.00).round(2))
          game.update(away_score: Random.rand(150.00).round(2))
        end
      end
    end
  end
end
