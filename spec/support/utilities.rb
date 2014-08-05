def join_league(league, user)
  team_name = FactoryGirl.generate(:random_name)
  Team.create!(name: team_name, user_id: user.id, league_id: league.id)
end