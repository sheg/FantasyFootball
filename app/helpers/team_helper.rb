module TeamHelper

  def get_league_week_stats(league_week = nil)
    game = self.league.get_nfl_week_game_from_league_week(league_week)
    return unless game

    players = self.get_roster(league_week)
    PointsCalculator.new.get_nfl_player_game_data(players, game.season.year, game.season_type_id, game.week)
  end

  def get_roster(league_week = nil)
    players = TeamTransaction.get_players_for_league_team(self.league_id, self.id, league_week)
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

  def draft_player(player_id, do_catchup = true)
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
        transaction_date: Time.now.utc,
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

end
