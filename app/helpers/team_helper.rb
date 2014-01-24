module TeamHelper

  # Need to allow for a way to see roster for a given week
  #   Use a date to limit the transaction records to pull.  Date should be something like the following Monday given an NFL week
  #   i.e. Find the date of a game in week 1, then find the following Monday and that date represents the date for transactions done during week 1
  def get_current_roster
    player_ids = TeamTransaction.includes(:nfl_player).get_player_ids_for_league_team(self.league_id, self.id)
    players = NflPlayer.where(id: player_ids).to_a
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
    players = TeamTransaction.get_player_ids_for_league_team(self.league_id, self.id).to_a

    unless(players.include?(player_id))
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
