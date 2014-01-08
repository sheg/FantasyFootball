Feature: Player card
  Each player card should display the following based on position type in the following order:


  { position_id: NflPosition['QB'], stat_type_id: StatType['PassingAttempts'].id},
  { position_id: NflPosition['QB'], stat_type_id: StatType['PassingCompletions'].id},
  { position_id: NflPosition['QB'], stat_type_id: StatType['PassingYards'].id},
  { position_id: NflPosition['QB'], stat_type_id: StatType['PassingTouchdowns'].id},
  { position_id: NflPosition['QB'], stat_type_id: StatType['PassingInterceptions'].id},
  { position_id: NflPosition['QB'], stat_type_id: StatType['RushingAttempts'].id},
  { position_id: NflPosition['QB'], stat_type_id: StatType['RushingYards'].id},
  { position_id: NflPosition['QB'], stat_type_id: StatType['RushingTouchdowns'].id},
  { position_id: NflPosition['QB'], stat_type_id: StatType['FumblesLost'].id},

  { position_id: NflPosition['RB'], stat_type_id: StatType['RushingAttempts'].id},
  { position_id: NflPosition['RB'], stat_type_id: StatType['RushingYards'].id},
  { position_id: NflPosition['RB'], stat_type_id: StatType['RushingYardsPerAttempt'].id},
  { position_id: NflPosition['RB'], stat_type_id: StatType['RushingTouchdowns'].id},
  { position_id: NflPosition['RB'], stat_type_id: StatType['ReceivingTargets'].id}, #For now...
  { position_id: NflPosition['RB'], stat_type_id: StatType['Receptions'].id},
  { position_id: NflPosition['RB'], stat_type_id: StatType['ReceivingYards'].id},
  { position_id: NflPosition['RB'], stat_type_id: StatType['ReceivingTouchdowns'].id},
  { position_id: NflPosition['RB'], stat_type_id: StatType['FumblesLost'].id},

  { position_id: NflPosition['WR'], stat_type_id: StatType['RushingYards'].id},
  { position_id: NflPosition['WR'], stat_type_id: StatType['RushingTouchdowns'].id},
  { position_id: NflPosition['WR'], stat_type_id: StatType['ReceivingTargets'].id},
  { position_id: NflPosition['WR'], stat_type_id: StatType['Receptions'].id},
  { position_id: NflPosition['WR'], stat_type_id: StatType['ReceivingYards'].id},
  { position_id: NflPosition['WR'], stat_type_id: StatType['ReceivingYardsPerReception'].id},
  { position_id: NflPosition['WR'], stat_type_id: StatType['ReceivingTouchdowns'].id},
  { position_id: NflPosition['WR'], stat_type_id: StatType['FumblesLost'].id},

  { position_id: NflPosition['TE'], stat_type_id: StatType['ReceivingTargets'].id},
  { position_id: NflPosition['TE'], stat_type_id: StatType['Receptions'].id},
  { position_id: NflPosition['TE'], stat_type_id: StatType['ReceivingYards'].id},
  { position_id: NflPosition['TE'], stat_type_id: StatType['ReceivingYardsPerReception'].id},
  { position_id: NflPosition['TE'], stat_type_id: StatType['ReceivingTouchdowns'].id},
  { position_id: NflPosition['TE'], stat_type_id: StatType['FumblesLost'].id},

  { position_id: NflPosition['K'], stat_type_id: StatType['FieldGoalsAttempted'].id},
  { position_id: NflPosition['K'], stat_type_id: StatType['FieldGoalsMade'].id},
  { position_id: NflPosition['K'], stat_type_id: StatType['FieldGoalPercentage'].id},
  { position_id: NflPosition['K'], stat_type_id: StatType['FieldGoalsLongestMade'].id},
  { position_id: NflPosition['K'], stat_type_id: StatType['ExtraPointsMade'].id},
  #Can't find a breakdown of ranges of kicks made - might have to create this at some point
  #e.g. 1-39 yards, 40-49 yards, 50+ yards


  { position_id: NflPosition['DST'], stat_type_id: StatType['DefensiveTouchdowns'].id},
  { position_id: NflPosition['DST'], stat_type_id: StatType['Interceptions'].id},
  { position_id: NflPosition['DST'], stat_type_id: StatType['KickReturnTouchdowns'].id},
  { position_id: NflPosition['DST'], stat_type_id: StatType['FumblesRecovered'].id},
  { position_id: NflPosition['DST'], stat_type_id: StatType['Sacks'].id},
  { position_id: NflPosition['DST'], stat_type_id: StatType['Safeties'].id},
  { position_id: NflPosition['DST'], stat_type_id: StatType['BlockedKicks'].id},
  { position_id: NflPosition['DST'], stat_type_id: StatType['PointsAllowed'].id},

  #/TeamGameStats/2013/1    ---- Get Team Stats per Game for Season for Week ... wasn't able to find this anywhere else
  { position_id: NflPosition['DST'], stat_type_id: StatType['OpponentOffensiveYards'].id},


  # I am assuming this is games played - would need this for non weekly breakdown views
  { position_id: NflPosition['?'], stat_type_id: StatType['Played'].id}

  #would come from us dynamically, just worth mentioning
  { position_id: NflPosition['?'], stat_type_id: StatType['FantasyPoints'].id}

  #Good Shabbos