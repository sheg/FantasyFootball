def create_league(league_size = 0, open_teams = 0, draft_started = false, is_private = false)
  league_name = Faker::Company.catch_phrase
  league_size = [10, 12].sample if league_size == 0
  league_type = [1, 2, 3].sample
  entry = [25.00, 50.00, 100.00, 150.00].sample
  if draft_started
    draft_date = Random.rand(90).days.ago
  else
    draft_date = Random.rand(90).days.from_now
  end

  new_league = League.create!(name: league_name, size: league_size,
                              league_type_id: league_type, entry_amount: entry,
                              fee_percent: 0.20, draft_start_date: draft_date, is_private: is_private)

  (new_league.size - open_teams).times do
    user_email = "#{Random.rand(100000)}.#{Faker::Internet.email}"
    user_first_name = Faker::Name.first_name
    user_last_name = Faker::Name.last_name
    new_user = User.create!(email: user_email, first_name: user_first_name,
                            last_name: user_last_name, password: "a"*6,
                            password_confirmation: "a"*6)

    team_name = "#{Faker::Name.title}--#{Random.rand(1000000)}"
    Team.create!(name: team_name, user_id: new_user.id, league_id: new_league.id)
  end
  League.find(new_league.id)
end

def join_league(league, user)
  team_name = "#{Faker::Name.title}--#{Random.rand(1000000)}"
  Team.create!(name: team_name, user_id: user.id, league_id: league.id)
end