namespace :fake_data do
  desc "Fill database with 10 fake leagues"
  task populate_leagues: :environment do
    3.times do
      league_name = Faker::Company.catch_phrase
      league_size = [10, 12].sample
      new_league = League.create!(name: league_name, size: league_size)
      new_league.size.times do
        user_email = "#{Random.rand(100000)}.#{Faker::Internet.email}"
        new_user = User.create!(email: user_email, password: "a"*6, password_confirmation: "a"*6)
        team_name = "#{Faker::Name.title}--#{Random.rand(1000000)}"
        new_team = Team.create!(name: team_name, user_id: new_user.id, league_id: new_league.id)
        puts "Adding #{new_team.name} to League Name: #{new_league.name} with user #{new_user.email}"
      end
    end

    3.times do #add a few unfilled leagues
      league_name = Faker::Company.catch_phrase
      league_size = [10, 12].sample
      new_league = League.create!(name: league_name, size: league_size)
      (new_league.size - 2).times do
        user_email = "#{Random.rand(100000)}.#{Faker::Internet.email}"
        new_user = User.create!(email: user_email, password: "a"*6, password_confirmation: "a"*6)
        team_name = "#{Faker::Name.title}--#{Random.rand(1000000)}"
        new_team = Team.create!(name: team_name, user_id: new_user.id, league_id: new_league.id)
        puts "Adding #{new_team.name} to League Name: #{new_league.name} with user #{new_user.email}"
      end
    end
  end

  desc "Set all league schedules"
  task set_schedules: :environment do
    include LeaguesHelper
    leagues = League.where.not(id: nil)
    leagues.each do |league|
      set_schedule(league) if league.available_teams == 0
    end
  end
end