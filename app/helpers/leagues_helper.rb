module LeaguesHelper

  def set_schedule(league)
    league_teams = league.teams.to_a
    weeks = create_schedule(league)
    weeks.each_with_index do |week, week_index|
      week.each_slice(2).to_a.each do |team_game_pair|
        week = (week_index + 1)
        home_team = league_teams[team_game_pair.first - 1].id
        away_team = league_teams[team_game_pair.last - 1].id
        game = Game.create!(week: week, home_team_id: home_team, away_team_id: away_team)
        Schedule.create!(league_id: league.id, game_id: game.id)
      end
    end
  end

  def create_schedule(league)
    game_values = (1..league.size).to_a
    weeks = []
    (league.size - 1).times do |week_index| #unique weeks = league size - 1
      games = []
      games[0] = 1

      (league.size - 1).times do |game_index|
        league.size.times do |valid_index|
          team_two = game_values[(week_index + (game_index + 2) + valid_index) % league.size ]
          if is_game_valid?(weeks, (game_index + 1),team_two,games)
            games[game_index + 1] = team_two
            break
          end
        end
      end
      weeks.push(games)
    end

    (13 - (league.size - 1)).times do |remaining_week_index|
      weeks.push (weeks[remaining_week_index]).reverse
    end
    weeks
  end

  def is_game_valid?(weeks, slot, team, games)
    !weeks.find { |past_games| past_games[slot] == team } && !games.include?(team)
  end
end