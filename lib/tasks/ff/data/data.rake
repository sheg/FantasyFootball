namespace :ff do
  namespace :data do
    desc "Fill database with 10 fake leagues"
    task populate_leagues: :environment do
      3.times { League.new.create_test_league }
      3.times { League.new.create_test_league(0, 3)}
    end

    desc "Run draft on specified league_id"
    task :league_draft, [:league_id] => :environment do |t, args|
      League.find_by(id: args[:league_id]).test_draft
    end
  end
end
