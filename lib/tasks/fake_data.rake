namespace :fake_data do
  desc "Fill database with 10 fake leagues"
  task populate_leagues: :environment do
    10.times do
      league_name = Faker::Company.catch_phrase
      league_size = [10, 12].sample
      new_league = League.create!(name: league_name, size: league_size)
      new_league.size.times do
        team_name = "#{Faker::Name.title}--#{Random.rand(1000000)}"
        user_email = "#{Random.rand(100000)}.#{Faker::Internet.email}"
        new_team = Team.create!(name: team_name)
        new_user = User.create!(email: user_email, password: "a"*6, password_confirmation: "a"*6)
        new_team.league = new_league
        new_team.user = new_user
        new_team.save!
        puts "Adding #{new_team.name} to League Name: #{new_league.name} with user #{new_user.email}"
      end
    end
  end
end