module LeaguesHelper

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

  def test_draft()
    set_draft_order
    team = self.get_current_draft_team
    while(team)
      slots = self.league_type.get_starting_slots
      round = self.get_current_draft_round
      slot = (round - 1) % slots.count
      position = slots[slot].shuffle.first
      players = NflPlayer.find_position(position).to_a.shuffle

      begin
        team.draft_player(players.first.id)
        puts "DraftOrder #{team.draft_order}: Team #{team.name} drafted position #{position}: #{players.first.full_name}"
      rescue Exception => e
        puts "DraftOrder #{team.draft_order}: Team #{team.name} failed to draft position #{position}: #{players.first.full_name}"
        puts "   #{e.message}"
      end

      team = self.get_current_draft_team
    end
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

  def set_draft_order
    return unless self.teams.count == self.size
    return if self.teams.first.draft_order

    order = (1..self.size).to_a.shuffle
    self.teams.each_with_index { |team, i|
      team.draft_order = order[i]
      team.save
    }
  end

  def get_draft_order()
    draft_teams = self.teams.order(:draft_order).to_a
    order = []

    self.roster_count.times do
      order += draft_teams
      draft_teams = draft_teams.reverse
    end

    order
  end

  def get_current_draft_team()
    transactions = draft_transactions.to_a
    order = get_draft_order
    team = nil

    if(transactions.count < order.count)
      team = order[transactions.count]
    end

    return team
  end

  def get_current_draft_pick_decimal()
    return "#{get_current_draft_round}.#{get_current_draft_round_pick}"
  end

  def get_current_draft_round()
    return (draft_transactions.count / self.size).floor + 1
  end

  def get_current_draft_round_pick()
    return (draft_transactions.count % self.size) + 1
  end
end