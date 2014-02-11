module TeamHelper
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

  def get_roster(league_week = nil)
    #players = TeamTransaction.get_players_for_league_team(self.league_id, self.id, league_week)
    nfl_week_game = self.league.get_nfl_week_game_from_league_week(league_week)
    nfl_week_game = self.league.get_nfl_week_game_from_league_week(self.league.total_weeks) unless nfl_week_game

    results = ActiveRecord::Base.connection.execute("call GetTeamRoster(#{self.id}, #{nfl_week_game.season_type_id}, #{nfl_week_game.week}, true);")
    roster = results.each(as: :hash, symbolize_keys: true).to_a
    ActiveRecord::Base.connection.close

    return roster
  end

  def check_player_taken(player_id)
    if(self.league.draft_unique_players)
      taken_players = TeamTransaction.get_players_taken(self.league_id).to_a

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

  def add_drop_player(add_player_id, drop_player_id)
    TeamTransaction.transaction do
      drop_player(drop_player_id)
      add_player(add_player_id)
    end
  end

  def add_player(player_id)
    check_player_taken(player_id)

    TeamTransaction.create(
        league_id: self.league.id,
        to_team_id: self.id,
        nfl_player_id: player_id,
        transaction_date: Time.now.utc,
        activity_type_id: ActivityType.ADD.id
    )
  end

  def drop_player(player_id)
    players = TeamTransaction.get_players_for_league_team(self.league_id, self.id).to_a

    unless(players.find { |p| p.id == player_id })
      player = NflPlayer.find_by(id: player_id)
      raise "#{player.full_name} is not on the team"
    end

    TeamTransaction.create!(
        league_id: self.league.id,
        from_team_id: self.id,
        nfl_player_id: player_id,
        transaction_date: Time.now.utc,
        activity_type_id: ActivityType.DROP.id
    )
  end

  def add_starters(players, league_week = nil)
    players = [players] unless players.is_a?(Array)
    roster = get_roster().map { |r| r[:player_id] }
    league_week = self.league.get_league_week_data.week_number unless league_week
    league_week = [self.league.total_weeks, league_week].min
    nfl_week = self.league.get_nfl_week(league_week)

    puts roster.inspect
    puts players.inspect
    ActiveRecord::Base.transaction do
      begin
        starters = Starter.where(team_id: self.id, week: league_week, active: true).map { |s| s.player_id }
        invalid = players - roster
        if(invalid.count > 0)
          raise "Cannot start players, not on roster [#{invalid.join(', ')}]"
        end

        new_starters = players | starters
        players = NflPlayer.where(id: new_starters).to_a

        positions = []
        players.each { |player|
          position = player.position_for_week(nfl_week[:season_type_id], nfl_week[:week])
          unless position
            raise "Invalid starter, PlayerId #{player.id}, cannot find position for league week #{league_week}"
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

  def drop_starters(players, league_week = nil)
    players = [players] unless players.is_a?(Array)
    league_week = self.league.get_league_week_data.week_number unless league_week
    league_week = [self.league.total_weeks, league_week].min

    ActiveRecord::Base.transaction do
      begin
        starter = Starter.where(team_id: self.id, week: league_week, player_id: players).destroy_all
      rescue Exception => e
        puts e.message[0,400]
        puts e.backtrace.join("\n   ")
        raise ActiveRecord::Rollback
      end
    end
  end

end
