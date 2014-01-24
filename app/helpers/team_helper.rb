module TeamHelper

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

  def draft_player(player_id)
    if(self.league.draft_pick_time > 0)
      current_team = self.league.get_current_draft_team
      last_pick = TeamTransaction.get_latest_pick_time(self.league_id)
      last_pick = Time.now.utc unless last_pick
      next_pick = last_pick + self.league.draft_pick_time
      now = Time.now.utc

      if(current_team.id != self.id)
        raise "Team #{self.name} cannot draft, current pick is #{current_team.name}, #{(next_pick - now).round(0)} seconds left to pick"
      end

      #if(now < next_pick)
      #  raise "Too soon to make draft pick, wait another #{(next_pick - now).round(0)} seconds"
      #end
    end

    check_player_taken(player_id)

    TeamTransaction.create(
        league_id: self.league.id,
        to_team_id: self.id,
        nfl_player_id: player_id,
        transaction_date: Time.now.utc,
        activity_type_id: ActivityType.DRAFT.id,
        draft_round: self.league.get_current_draft_round,
        draft_pick: self.league.get_current_draft_round_pick
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
