module LeaguesHelper

  #def current_league?(league)
  #  league == current_league
  #end

  #def current_league
  #  if params[:team_id]
  #    team = Team.find_by(id: params[:team_id])
  #    redirect_to(leagues_url, notice: "Could not find a league with team_id #{params[:team_id]}") unless team
  #    @current_league = team.league
  #  elsif params[:league_id]
  #    league = League.includes(games: [:home_team, :away_team]).find_by(id: params[:league_id])
  #    redirect_to(leagues_url, notice: "Could not find a league with team_id #{params[:team_id]}") unless league
  #    @current_league ||= league
  #  else
  #    redirect_to(leagues_url, notice: "Can't find current league - no parameters supplied")
  #  end
  #end

  def create_test_league(league_size = 0, open_teams = 0)
    league_name = Faker::Company.catch_phrase
    league_size = [10, 12].sample if league_size == 0
    league_type = [1, 2, 3].sample
    entry = [25.00, 50.00, 100.00, 150.00].sample

    new_league = League.create!(name: league_name, size: league_size,
                                league_type_id: league_type, entry_amount: entry,
                                fee_percent: 0.20)

    (new_league.size - open_teams).times do
      user_email = "#{Random.rand(100000)}.#{Faker::Internet.email}"
      new_user = User.create!(email: user_email, password: "a"*6, password_confirmation: "a"*6)
      team_name = "#{Faker::Name.title}--#{Random.rand(1000000)}"
      new_team = Team.create!(name: team_name, user_id: new_user.id, league_id: new_league.id)
      puts "Adding #{new_team.name} to League Name: #{new_league.name} with user #{new_user.email}"
    end
    League.find(new_league.id)
  end

  def set_schedule
    return unless self.teams.count == self.size
    return if Game.where(league_id: self.id).count > 0

    league_teams = self.teams.to_a
    weeks = create_schedule
    weeks.each_with_index do |week, week_index|
      week.each_slice(2).to_a.each do |team_game_pair|
        week = (week_index + 1)
        home_team = league_teams[team_game_pair.first - 1].id
        away_team = league_teams[team_game_pair.last - 1].id
        Game.create!(league_id: self.id, week: week, home_team_id: home_team, away_team_id: away_team)
      end
    end
  end

  def create_schedule
    weeks = []

    count = self.size
    unique_weeks = count - 1
    games_per_week = count / 2
    for week in 0...unique_weeks
      for i in 0...games_per_week

        x = (week + i) % (count - 1)
        y = (count - 1 - i + week) % (count - 1)

        if i == 0
          y = count - 1
        end

        weeks.push x + 1
        weeks.push y + 1
      end
    end

    weeks = weeks.each_slice(count).to_a

    remaining_games = (self.weeks - (self.size - 1))
    remaining_games.times do |remaining_week_index|
      weeks.push (weeks[remaining_week_index]).reverse
    end
    weeks
  end
end