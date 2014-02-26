module TeamHelper

  def leave_league(league, team)
    unless league.started?
      if team
        team.destroy!
        redirect_to(leagues_path, notice: "Thanks for playing - Please choose from any other leagues below")
      else
        redirect_to(leagues_path, notice: "No Team Selected...")
      end
    else
      redirect_to(league_path(self), notice: "League has already started - please contact customer service for further assistance")
    end
  end

  def get_league_week_stats(league_week = nil)
    game = self.league.get_nfl_week_game_from_league_week(league_week)
    roster = self.get_roster(league_week)
    player_ids = roster.map { |r| r[:player_id] }
    players = NflPlayer.where(id: player_ids).to_a

    data = PointsCalculator.new.get_nfl_player_game_data(players, game.season.year, game.season_type_id, game.week)
    game_players = data.map { |d| d.game_player }
    league_points = LeaguePlayerPoint.where(league_id: self.league_id, nfl_game_player_id: game_players).to_a
    league_points.each { |league_point|
      data.find { |d| d.game_player and d.game_player.id == league_point.nfl_game_player_id }.league_points = league_point.points
    }

    roster.find_all { |r| r[:started] == 1 }.each { |r|
      data.find { |d| d.player and d.player.id == r[:player_id] }.started = r[:started]
    }

    return data
  end

  def get_league_week_stats_grouped(league_week = nil)
    data = get_league_week_stats(league_week)
    grouped = Hash.new

    starter_groups = data.group_by { |d| d.started? }

    grouped[:starters] = self.league.league_type.populate_positions(starter_groups[true])
    grouped[:starters] = [] unless grouped[:starters]
    grouped[:bench] = starter_groups[false]
    grouped[:bench] = [] unless grouped[:bench]
    grouped[:bench] = grouped[:bench].sort { |a, b| a.position.sort_order <=> b.position.sort_order }.group_by { |d| d.position.abbr }

    grouped
  end

  def get_roster(league_week = nil)
    unless @roster
      #players = TeamTransaction.get_players_for_league_team(self.league_id, self.id, league_week)
      nfl_week_game = self.league.get_nfl_week_game_from_league_week(league_week)
      nfl_week_game = self.league.get_nfl_week_game_from_league_week(self.league.total_weeks) unless nfl_week_game

      results = ActiveRecord::Base.connection.execute("call GetTeamRoster(#{self.id}, #{nfl_week_game.season_type_id}, #{nfl_week_game.week}, true);")
      @roster = results.each(as: :hash, symbolize_keys: true).to_a
      ActiveRecord::Base.connection.close
    end

    return @roster
  end

  def check_player_taken(player_id, league_week = nil)
    if(self.league.draft_unique_players)
      taken_players = TeamTransaction.get_players_taken(self.league_id, league_week).to_a

      if(taken_players.include?(player_id))
        player = NflPlayer.find_by(id: player_id)
        raise "#{player.full_name} is already taken"
      end
    end
  end

  def draft_player(player_id, do_catchup = true, override_transaction_date = nil)
    current_draft_info = League::DraftInfo.new

    if(self.league.draft_pick_time > 0)
      self.league.catchup_draft if do_catchup
      current_draft_info = self.league.get_current_draft_info

      if(current_draft_info.current_team.id != self.id)
        raise "Team #{self.name} cannot draft, current pick is #{current_draft_info.current_team.name}, #{current_draft_info.time_left} seconds left to pick"
      end
    end

    check_player_taken(player_id)

    TeamTransaction.create(
        league_id: self.league.id,
        to_team_id: self.id,
        nfl_player_id: player_id,
        transaction_date: (override_transaction_date ? override_transaction_date : Time.now.utc),
        activity_type_id: ActivityType.DRAFT.id,
        draft_round: current_draft_info.draft_round,
        draft_pick: current_draft_info.draft_round_pick
    )
  end

  def add_drop_player(add_player_id, drop_player_id, league_week = nil, now = nil)
    get_roster(league_week)
    TeamTransaction.transaction do
      drop_player(drop_player_id, league_week, now)
      add_player(add_player_id, league_week, now)
    end
  end

  def add_player(player_id, league_week = nil, now = nil)
    check_player_taken(player_id, league_week)
    process_roster_change(ActivityType.ADD, player_id, league_week, now)
  end

  def drop_player(player_id, league_week = nil, now = nil)
    process_roster_change(ActivityType.DROP, player_id, league_week, now)
  end

  def process_roster_change(activity_type, player_id, league_week = nil, now = nil)
    roster = get_roster(league_week).map { |r| r[:player_id] }
    player = NflPlayer.find_by(id: player_id)
    now = Time.now unless now
    now = Time.parse(now) if now.is_a? String
    now = now.utc

    raise "#{player.full_name} is not on the team" unless(roster.include?(player_id)) if activity_type.id == ActivityType.DROP.id

    week_data = self.league.get_league_week_data_for_week(league_week)
    raise "League is over" unless week_data

    transaction_date = Time.now
    transaction_date = (week_data.start_date + 1.days).beginning_of_day if league_week
    transaction_date = transaction_date.utc

    nfl_week = self.league.get_nfl_week(week_data.week_number)

    game = player.game_for_week(nfl_week[:season_type_id], nfl_week[:week])
    if game
      if game.start_time <= now
        raise "Cannot process #{player.full_name} (Id #{player.id}), NFL game has already started"
      end
    end

    if activity_type.id == ActivityType.DROP.id
      starters = Starter.where(team_id: self.id, player_id: player_id).where('week >= ?', week_data.week_number)
      starters.destroy_all if starters
    end

    transaction = TeamTransaction.new(
        league_id: self.league.id,
        from_team_id: 0,
        to_team_id: 0,
        nfl_player_id: player_id,
        transaction_date: transaction_date,
        activity_type_id: activity_type.id
    )
    transaction.from_team_id = self.id if activity_type.id == ActivityType.DROP.id
    transaction.to_team_id = self.id if activity_type.id == ActivityType.ADD.id
    transaction.save!
  end
  private :process_roster_change

  def get_starters(league_week)
    starter = Starter.where(team_id: self.id, week: league_week, active: true).to_a
  end

  def add_starters(player_ids, league_week = nil, now = nil)
    player_ids = [player_ids] unless player_ids.is_a?(Array)
    roster = get_roster(league_week).map { |r| r[:player_id] }
    league_week = self.league.get_league_week_data.week_number unless league_week
    league_week = [self.league.total_weeks, league_week].min
    nfl_week = self.league.get_nfl_week(league_week)
    now = Time.now unless now
    now = Time.parse(now) if now.is_a? String
    now = now.utc

    ActiveRecord::Base.transaction do
      begin
        invalid = player_ids - roster
        if(invalid.count > 0)
          raise "Cannot start players, not on roster [#{invalid.join(', ')}]"
        end

        starters = Starter.where(team_id: self.id, week: league_week, active: true).map { |s| s.player_id }
        new_starters = player_ids | starters
        players = NflPlayer.where(id: new_starters).to_a

        positions = []
        players.each { |player|
          if player_ids.include?(player.id) and not starters.include?(player.id)
            game = player.game_for_week(nfl_week[:season_type_id], nfl_week[:week])
            if game
              if game.start_time <= now
                raise "Cannot add #{player.full_name} (Id #{player.id}), NFL game has already started"
              end
            end
          end

          position = player.position_for_week(nfl_week[:season_type_id], nfl_week[:week])
          unless position
            raise "Cannot add #{player.full_name} (Id #{player.id}), cannot find position for league week #{league_week}"
          end
          positions.push(position.abbr)
        }

        unless(self.league.league_type.validate_starting_positions(positions))
          raise "Invalid starting lineup for league type, starting positions [#{positions.join(', ')}]"
        end

        new_starters.each { |id|
          starter = Starter.find_or_create_by(team_id: self.id, week: league_week, player_id: id)
          starter.active = true
          starter.save
        }
      rescue Exception => e
        puts e.message[0,400]
        puts e.backtrace.join("\n   ")
        raise ActiveRecord::Rollback
      end
    end
  end

  def drop_starters(players, league_week = nil, now = nil)
    players = [players] unless players.is_a?(Array)
    league_week = self.league.get_league_week_data.week_number unless league_week
    league_week = [self.league.total_weeks, league_week].min
    nfl_week = self.league.get_nfl_week(league_week)
    now = Time.now unless now
    now = Time.parse(now) if now.is_a? String
    now = now.utc

    ActiveRecord::Base.transaction do
      begin
        players = NflPlayer.where(id: players).to_a
        players.each { |player|
          game = player.game_for_week(nfl_week[:season_type_id], nfl_week[:week])
          if game
            if game.start_time <= now
              raise "Cannot drop #{player.full_name} (Id #{player.id}), NFL game has already started"
            end
          end
        }

        starters = Starter.where(team_id: self.id, week: league_week, player_id: players)
        starters.destroy_all if starters
      rescue Exception => e
        puts e.message[0,400]
        puts e.backtrace.join("\n   ")
        raise ActiveRecord::Rollback
      end
    end
  end

end
