namespace :fake_data do
  desc "Fill database with 10 fake leagues"
  task populate_leagues: :environment do
    3.times { League.new.create_test_league }
    3.times { League.new.create_test_league(0, 3)}
  end

  #desc "Set all league schedules"
  #task set_schedules: :environment do
  #  include LeaguesHelper
  #  leagues = League.where.not(id: nil)
  #  leagues.each do |league|
  #    set_schedule(league) if league.available_teams == 0
  #  end
  #end
end