namespace :fake_data do
  desc "Fill database with 20 fake leagues"
  task populate_leagues: :environment do
    20.times do
      league_name = Faker::Company.catch_phrase
      league_size = [10, 12].sample
      new_league = League.create!(name: league_name, size: league_size)
      teams = []
      new_league.size.times do
        team_name = "#{Faker::Name.title}--#{Random.rand(1000000)}"
        new_team = Team.create!(name: team_name)
        teams.push(new_team)
        puts "Adding #{new_team.name} to League Name: #{new_league.name}"
      end
      new_league.teams << teams
    end
  end
end