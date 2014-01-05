namespace :ff do
  namespace :data do
    desc "Fill database with 10 fake leagues"
    task populate_leagues: :environment do
      3.times { League.new.create_test_league }
      3.times { League.new.create_test_league(0, 3)}
    end
  end
end
