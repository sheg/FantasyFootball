module LeaguesHelper
  class WeekData
    attr_accessor :week_number,
                  :start_date

    def initialize
      self.week_number = 0
    end

    def end_date
      (start_date + 1.week - 1.day).end_of_day
    end
  end

  class DraftInfo
    attr_accessor :current_team,
                  :draft_round,
                  :draft_round_pick,
                  :last_pick_time,
                  :next_pick_time

    def draft_pick_decimal
      return "#{draft_round}.#{draft_round_pick}"
    end

    def time_left
      return (next_pick_time.to_time - Time.now.utc).round(0)
    end
  end

  def set_league_week_data
    return if self.nfl_start_week
    return if self.available_teams > 0
    return if draft_transactions.count < self.teams_count * self.roster_count

    data = get_league_week_data_for_week(1)
    nfl_game = get_nfl_week_game(data)

    unless nfl_game
      nfl_game = NflGame.where(season_type_id: 1, week: 1).order(start_time: :desc).first
      raise "The season is over" if nfl_game.start_time < data.start_date

      data.start_date = nfl_game.start_time.beginning_of_week - 1.week + 2.days
    end

    self.nfl_start_week = nfl_game.week
    self.nfl_start_week += 17 if nfl_game.season_type_id == 3
    self.nfl_start_week = 1 if nfl_game.season_type_id == 2

    self.start_week_date = data.start_date
    self.start_week_date += (5 - nfl_game.week).weeks if nfl_game.season_type_id == 2

    self.save
  end

  def get_league_week_data_for_week(league_week = nil)
    week_data = get_league_week_data
    league_week = week_data.week_number unless league_week

    return nil if league_week > self.total_weeks or league_week <= 0

    week_data.week_number = 1 if(week_data.week_number == 0)    # 0 is returned when league hasn't started yet

    week_data.start_date += (league_week - week_data.week_number).weeks
    week_data.week_number = league_week
    return week_data
  end

  def get_league_week_data(date = nil)
    start_week = nil
    week = WeekData.new

    if(self.start_week_date)
      start_week = self.start_week_date
    else
      transactions = draft_transactions.to_a
      order = get_draft_order
    end

    if(start_week or transactions.count == order.count)
      # Use the next upcoming Tuesday as the start of week
      start_day_of_week = 2

      unless(start_week)
        # Get last draft pick as league start time and add 1 week if it is on start day of week or later
        max_transaction = transactions.max_by { |t| t.transaction_date }.transaction_date
        max_transaction += 1.week if max_transaction.wday >= start_day_of_week

        start_week = max_transaction
      end

      start_week = (start_week.beginning_of_week.at_beginning_of_day + start_day_of_week.days).to_date

      date = DateTime.now unless date
      date = date.utc.at_beginning_of_day.to_date

      days = (date - start_week).to_i
      if(days < 0)
        week.week_number = 0
        week.start_date = start_week
      else
        week.week_number = (days / 7).floor + 1
        week.start_date = start_week + (week.week_number - 1).weeks
      end
    end

    return week
  end

  def get_nfl_week_game(league_week_data)
    game = nil
    if(league_week_data)
      # Adding extra weeks to end date in case of missing weeks (i.e. skipped week before super bowl)
      games = NflGame.where('start_time between ? and ?', league_week_data.start_date + 1.days, league_week_data.end_date + 2.week + 1.days).order(:start_time)
      if(games.count > 0)
        game = games.first
      end
    end
    return game
  end

  def get_nfl_week_game_from_league_week(league_week)
    week_data = get_league_week_data_for_week(league_week)
    get_nfl_week_game(week_data)
  end

  def is_waiver_period?(now = nil)
    now = Time.now unless now
    now = Time.parse(now) if now.is_a? String
    now = now.utc

    week_data = get_league_week_data(now)
    now < (week_data.start_date + 2.days)
  end

  def get_waiver_order(league_week)
    order = []
    standings = self.team_standings.where(week: league_week).order(:percent, :points_for, points_against: :desc).order("rand()").to_a
  end

  def test_draft()
    set_draft_order

    catchup_draft
    while(true)
      pick = auto_draft_player
      break unless pick
    end
  end

  def catchup_draft
    current_draft_info = self.get_current_draft_info
    while(current_draft_info and current_draft_info.time_left < 0)
      pick = self.auto_draft_player(current_draft_info)
      break unless pick
      current_draft_info = self.get_current_draft_info
    end
  end

  def auto_draft_player(draft_info = nil)
    draft_info = self.get_current_draft_info unless draft_info
    return nil unless draft_info

    slots = self.league_type.get_starting_slots
    round = draft_info.draft_round
    slot = (round - 1) % slots.count
    position = slots[slot].sample

    @position_players = {} unless @position_players
    unless @position_players[position]
      @position_players[position] = NflPlayer.find_position(position).where("nfl_games.season_id between #{season_id} - 1 and #{season_id}")
        .select("nfl_players.*, sum(nfl_game_players.points) as points").group("nfl_players.id").order("points desc").to_a
    end
    players = @position_players[position]

    pick = nil
    @retry_num = 0
    while(pick.nil?)
      begin
        break if @retry_num >= 10

        player = players.slice!(0)

        # Adjust the transaction date in case this draft was made after time expired for that pick
        if(draft_info.time_left < 0)
          transaction_date = draft_info.next_pick_time
        else
          transaction_date = nil
        end
        pick = draft_info.current_team.draft_player(player.id, false, transaction_date)

        #puts "DraftOrder #{draft_info.current_team.draft_order}: Team #{draft_info.current_team.name} drafted position #{position}: #{player.full_name}"
      rescue Exception => e
        if e.message.include?("already taken")
          #puts "DraftOrder #{draft_info.current_team.draft_order}: Team #{draft_info.current_team.name} failed to draft position #{position}: #{player.full_name}"
          #puts "   #{e.message}"
          @retry_num += 1
        else
          raise e
        end
      end
    end

    return pick
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

  def get_current_draft_info()
    transactions = draft_transactions.to_a
    order = get_draft_order
    info = nil

    if(transactions.count < order.count)
      info = DraftInfo.new
      info.current_team = order[transactions.count]
      info.draft_round =  (transactions.count / self.size).floor + 1
      info.draft_round_pick = (transactions.count % self.size) + 1

      max_transaction = transactions.max_by { |t| t.transaction_date }
      info.last_pick_time = max_transaction.transaction_date if max_transaction
      info.last_pick_time = self.draft_start_date unless max_transaction
      info.last_pick_time = DateTime.now.utc unless info.last_pick_time

      info.next_pick_time = info.last_pick_time + self.draft_pick_time.seconds
    end

    return info
  end
end