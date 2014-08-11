namespace :ff do
  namespace :data do
    desc "Fill database with 10 fake leagues"
    task populate_leagues: :environment do
      3.times { FactoryGirl.create :league }
      3.times { FactoryGirl.create :partially_filled_league }
    end

    desc "Run draft on specified league_id"
    task :league_draft, [:league_id] => :environment do |t, args|
      id = args[:league_id]
      league = League.find_by(id: id)
      if league
        league.test_draft
      else
        puts "No such league ID #{id}"
      end
    end

    desc "Recalculate all League points, scores, standings, etc"
    task recalculate_points: :environment do
      PointsCalculator.new.update_game_player_points_for_games(NflGame.all)
    end
  end
end