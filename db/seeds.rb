# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts 'Seeding LeagueTypes'
league_types = [
    { name: 'Normal', starting_slots_json:'[ ["QB"], ["RB"], ["RB"], ["WR"], ["WR"], ["WR"], ["TE"], ["K"], ["DST"] ]',
        position_limits_json: '[]' },
    { name: 'Flex 9', starting_slots_json: '[ ["QB"], ["RB"], ["RB"], ["RB","WR","TE"], ["WR"], ["WR"], ["TE"], ["K"], ["DST"] ]',
        position_limits_json: '[]' },
    { name: 'Flex 10', starting_slots_json: '[ ["QB"], ["RB"], ["RB"], ["RB","WR","TE"], ["WR"], ["WR"], ["WR"], ["TE"], ["K"], ["DST"] ]',
        position_limits_json: '[]' },
    { name: 'Super Flex', starting_slots_json: '[ ["QB"], ["QB","RB"], ["RB"], ["RB","WR"], ["WR"], ["WR"], ["WR","TE"], ["TE"], ["K"], ["DST"] ]',
        position_limits_json: '[]' },
]
league_types.each do |data|
  item = LeagueType.find_or_create_by(name: data[:name])
  item.starting_slots_json = data[:starting_slots_json]
  item.position_limits_json = data[:position_limits_json]
  item.save
end

puts 'Seeding Activity Types'
activity_types = [
    { name: "draft", display_name: 'Draft' },
    { name: "add", display_name: 'Add' },
    { name: "drop", display_name: 'Drop' },
    { name: "trade", display_name: 'Trade' },
]
activity_types.each do |data|
  item = ActivityType.find_or_create_by(name: data[:name])
  item.display_name = data[:display_name]
  item.save
end

puts 'Seeding Transaction Statuses'
transaction_statuses = [
    { name: "completed", display_name: 'Completed' },
    { name: "pending", display_name: 'Pending' },
    { name: "cancelled", display_name: 'Cancelled' },
    { name: "rejected", display_name: 'Rejected' },
]
transaction_statuses.each do |data|
  item = TransactionStatus.find_or_create_by(name: data[:name])
  item.display_name = data[:display_name]
  item.save
end

puts 'Seeding Positions'
positions = [
  { abbr: "QB", name: 'Quarterback', sort_order: 10 },
  { abbr: "RB", name: 'Running Back', sort_order: 20 },
  { abbr: "WR", name: 'Wide Receiver', sort_order: 30 },
  { abbr: "TE", name: 'Tight End', sort_order: 40 },
  { abbr: "K", name: 'Kicker', sort_order: 50 },
  { abbr: "DST", name: 'Defense', sort_order: 60 },
]
positions.each do |data|
  position = NflPosition.find_or_create_by(abbr: data[:abbr])
  position.name = data[:name]
  position.sort_order = data[:sort_order]
  position.save
end
@positions = Hash[NflPosition.all.map{ |p| [p.abbr, p]}]

puts 'Seeding StatTypes'
stat_types = [
  { name: "PassingAttempts", group: 'Passing', abbr: 'Att', display_name: 'Passing Attempts' },
  { name: "PassingCompletions", group: 'Passing', abbr: 'Comp', display_name: 'Passing Completions' },
  { name: "PassingCompletionPercentage", group: 'Passing', abbr: 'Cmp%', display_name: 'Passing Completion %' },
  { name: "PassingYards", group: 'Passing', abbr: 'Yds', display_name: 'Passing Yards' },
  { name: "PassingYardsPerAttempt", group: 'Passing', abbr: 'Yd/A', display_name: 'Passing Yards Per Attempt' },
  { name: "PassingYardsPerCompletion", group: 'Passing', abbr: 'Yd/C', display_name: 'Passing Yards Per Completion' },
  { name: "PassingTouchdowns", group: 'Passing', abbr: 'TD', display_name: 'Passing Touchdowns' },
  { name: "PassingInterceptions", group: 'Passing', abbr: 'Int', display_name: 'Passing Interceptions' },
  { name: "PassingRating", group: 'Passing', abbr: 'Rating', display_name: 'Passing Rating' },
  { name: "PassingSacks", group: 'Passing', abbr: 'Sack', display_name: 'Passing Sacks' },
  { name: "PassingSackYards", group: 'Passing', abbr: 'SackYds', display_name: 'Passing Sack Yards' },
  { name: "TwoPointConversionPasses", group: 'Passing', abbr: '2Pt', display_name: 'Passing Two Point Conversions' },
  { name: "PassingLong", group: 'Passing', abbr: 'Long', display_name: 'Passing Longest' },
  { name: "ReceivingTargets", group: 'Receiving', abbr: 'Tgt', display_name: 'Targets' },
  { name: "Receptions", group: 'Receiving', abbr: 'Rcp', display_name: 'Receptions' },
  { name: "ReceptionPercentage", group: 'Receiving', abbr: 'Rcp%', display_name: 'Reception %' },
  { name: "ReceivingYards", group: 'Receiving', abbr: 'Yds', display_name: 'Yards' },
  { name: "ReceivingYardsPerTarget", group: 'Receiving', abbr: 'Yd/T', display_name: 'Yards Per Target' },
  { name: "ReceivingYardsPerReception", group: 'Receiving', abbr: 'Yd/R', display_name: 'Yards Per Reception' },
  { name: "ReceivingTouchdowns", group: 'Receiving', abbr: 'TD', display_name: 'Touchdowns' },
  { name: "ReceivingLong", group: 'Receiving', abbr: 'Long', display_name: 'Longest' },
  { name: "TwoPointConversionReceptions", group: 'Receiving', abbr: '2Pt', display_name: 'Two Point Conversions' },
  { name: "RushingAttempts", group: 'Rushing', abbr: 'Att', display_name: 'Attempts' },
  { name: "RushingYards", group: 'Rushing', abbr: 'Yds', display_name: 'Yards' },
  { name: "RushingYardsPerAttempt", group: 'Rushing', abbr: 'Yd/A', display_name: 'Yards Per Attempt' },
  { name: "RushingTouchdowns", group: 'Rushing', abbr: 'TD', display_name: 'Touchdowns' },
  { name: "RushingLong", group: 'Rushing', abbr: 'Long', display_name: 'Longest' },
  { name: "TwoPointConversionRuns", group: 'Rushing', abbr: '2Pt', display_name: 'Two Point Conversions' },
  { name: "FumblesLost", group: 'Fumbles', abbr: 'Fum', display_name: 'Lost' },
  { name: "FumblesRecovered", group: 'Fumbles', abbr: 'FRec', display_name: 'Recovered' },
  { name: "FumbleReturnYards", group: 'Fumbles', abbr: 'FRetYds', display_name: 'Return Yards' },
  { name: "FumbleReturnTouchdowns", group: 'Fumbles', abbr: 'FRetTD', display_name: 'Return Touchdowns' },
  { name: "Interceptions", group: 'Defense', abbr: 'Int', display_name: 'Interceptions' },
  { name: "InterceptionReturnYards", group: 'Defense', abbr: 'IntRetYds', display_name: 'Interception Return Yards' },
  { name: "InterceptionReturnTouchdowns", group: 'Defense', abbr: 'IntRetTD', display_name: 'Interception Return Touchdowns' },
  { name: "Sacks", group: 'Defense', abbr: 'Sack', display_name: 'Sacks' },
  { name: "Safeties", group: 'Defense', abbr: 'Sft', display_name: 'Safeties' },
  { name: "DefensiveTouchdowns", group: 'Defense', abbr: 'TD', display_name: 'Touchdowns' },
  { name: "PointsAllowed", group: 'Defense', abbr: 'PtAll', display_name: 'Points Allowed' },
  { name: "OpponentOffensiveYards", group: 'Defense', abbr: 'YdsAll', display_name: 'Yards Allowed' },
  { name: "KickReturnTouchdowns", group: 'Defense', abbr: 'KickRTD', display_name: 'Kick Return Touchdowns' },
  { name: "BlockedKicks", group: 'Defense', abbr: 'Blocked', display_name: 'Blocked Kicks' },
  { name: "ExtraPointsMade", group: 'Scoring', abbr: 'XP', display_name: 'Extra Points' },
  { name: "FieldGoalsMade", group: 'Scoring', abbr: 'FG', display_name: 'Field Goals' },
  { name: "FieldGoalsAttempted", group: 'Scoring', abbr: 'FGA', display_name: 'Field Goals Attempted' },
  { name: "FieldGoalPercentage", group: 'Scoring', abbr: 'FG%', display_name: 'Field Goals %' },
  { name: "FieldGoalsLongestMade", group: 'Scoring', abbr: 'FGLong', display_name: 'Field Goals Longest' },
]
stat_types.each do |data|
  stat_type = StatType.find_or_create_by(name: data[:name])
  stat_type.group = data[:group]
  stat_type.abbr = data[:abbr]
  stat_type.display_name = data[:display_name]
  stat_type.save
end
@stat_types = Hash[StatType.all.map{ |s| [s.name, s]}]

puts 'Seeding PositionStats'
position_stats = [
    { position: 'QB', stat_type: 'PassingAttempts', sort_order: 10 },
    { position: 'QB', stat_type: 'PassingCompletions', sort_order: 20 },
    { position: 'QB', stat_type: 'PassingYards', sort_order: 30 },
    { position: 'QB', stat_type: 'PassingTouchdowns', sort_order: 40 },
    { position: 'QB', stat_type: 'PassingInterceptions', sort_order: 50 },
    { position: 'QB', stat_type: 'RushingAttempts', sort_order: 60 },
    { position: 'QB', stat_type: 'RushingYards', sort_order: 70 },
    { position: 'QB', stat_type: 'RushingTouchdowns', sort_order: 80 },
    { position: 'QB', stat_type: 'FumblesLost', sort_order: 90 },

    { position: 'RB', stat_type: 'RushingAttempts', sort_order: 10 },
    { position: 'RB', stat_type: 'RushingYards', sort_order: 20 },
    { position: 'RB', stat_type: 'RushingYardsPerAttempt', sort_order: 30 },
    { position: 'RB', stat_type: 'RushingTouchdowns', sort_order: 40 },
    { position: 'RB', stat_type: 'ReceivingTargets', sort_order: 50 },
    { position: 'RB', stat_type: 'Receptions', sort_order: 60 },
    { position: 'RB', stat_type: 'ReceivingYards', sort_order: 70 },
    { position: 'RB', stat_type: 'ReceivingTouchdowns', sort_order: 80 },
    { position: 'RB', stat_type: 'FumblesLost', sort_order: 90 },

    { position: 'WR', stat_type: 'ReceivingTargets', sort_order: 30 },
    { position: 'WR', stat_type: 'Receptions', sort_order: 40 },
    { position: 'WR', stat_type: 'ReceivingYards', sort_order: 50 },
    { position: 'WR', stat_type: 'ReceivingYardsPerReception', sort_order: 60 },
    { position: 'WR', stat_type: 'ReceivingTouchdowns', sort_order: 70 },
    { position: 'WR', stat_type: 'RushingYards', sort_order: 73 },
    { position: 'WR', stat_type: 'RushingTouchdowns', sort_order: 75 },
    { position: 'WR', stat_type: 'FumblesLost', sort_order: 80 },

    { position: 'TE', stat_type: 'ReceivingTargets', sort_order: 30 },
    { position: 'TE', stat_type: 'Receptions', sort_order: 40 },
    { position: 'TE', stat_type: 'ReceivingYards', sort_order: 50 },
    { position: 'TE', stat_type: 'ReceivingYardsPerReception', sort_order: 60 },
    { position: 'TE', stat_type: 'ReceivingTouchdowns', sort_order: 70 },
    { position: 'TE', stat_type: 'FumblesLost', sort_order: 80 },

    { position: 'K', stat_type: 'FieldGoalsAttempted', sort_order: 10 },
    { position: 'K', stat_type: 'FieldGoalsMade', sort_order: 20 },
    { position: 'K', stat_type: 'FieldGoalPercentage', sort_order: 30 },
    { position: 'K', stat_type: 'FieldGoalsLongestMade', sort_order: 40 },
    { position: 'K', stat_type: 'ExtraPointsMade', sort_order: 50 },

    { position: 'DST', stat_type: 'DefensiveTouchdowns', sort_order: 10 },
    { position: 'DST', stat_type: 'Interceptions', sort_order: 20 },
    { position: 'DST', stat_type: 'KickReturnTouchdowns', sort_order: 30 },
    { position: 'DST', stat_type: 'FumblesRecovered', sort_order: 40 },
    { position: 'DST', stat_type: 'Sacks', sort_order: 50 },
    { position: 'DST', stat_type: 'Safeties', sort_order: 60 },
    { position: 'DST', stat_type: 'BlockedKicks', sort_order: 70 },
    { position: 'DST', stat_type: 'PointsAllowed', sort_order: 80 },
    { position: 'DST', stat_type: 'OpponentOffensiveYards', sort_order: 90 },

    # I am assuming this is games played - would need this for non weekly breakdown views
    #{ position: '?', stat_type: 'Played', sort_order: 10 },
]
position_stats.each do |data|
  position = @positions[data[:position]]
  stat_type = @stat_types[data[:stat_type]]

  item = NflPositionStat.find_or_create_by(nfl_position_id: position.id, stat_type_id: stat_type.id)
  item.sort_order = data[:sort_order]
  item.save
end

puts 'Seeding LeaguePointRules'
rules = [
  { league_id: nil, stat_type: 'FieldGoalsMade', multiplier: 3 },
  { league_id: nil, stat_type: 'FumblesLost', multiplier: -2 },
  { league_id: nil, stat_type: 'TwoPointConversionPasses', multiplier: 2 },
  { league_id: nil, stat_type: 'PassingInterceptions', multiplier: -2 },
  { league_id: nil, stat_type: 'PassingTouchdowns', multiplier: 6 },
  { league_id: nil, stat_type: 'PassingYards', multiplier: 0.04 },
  { league_id: nil, stat_type: 'TwoPointConversionReceptions', multiplier: 2 },
  { league_id: nil, stat_type: 'ReceivingTouchdowns', multiplier: 6 },
  { league_id: nil, stat_type: 'ReceivingYards', multiplier: 0.1 },
  { league_id: nil, stat_type: 'TwoPointConversionRuns', multiplier: 2 },
  { league_id: nil, stat_type: 'RushingTouchdowns', multiplier: 6 },
  { league_id: nil, stat_type: 'RushingYards', multiplier: 0.1 },
  { league_id: nil, stat_type: 'ExtraPointsMade', multiplier: 1 },
  { league_id: nil, stat_type: 'FumblesRecovered', multiplier: 2 },
  { league_id: nil, stat_type: 'DefensiveTouchdowns', multiplier: 6 },
  { league_id: nil, stat_type: 'Interceptions', multiplier: 2 },
  { league_id: nil, stat_type: 'Sacks', multiplier: 1 },
  { league_id: nil, stat_type: 'PointsAllowed', min_range: 0, max_range: 6, fixed_points: 8 },
  { league_id: nil, stat_type: 'PointsAllowed', min_range: 7, max_range: 13, fixed_points: 6 },
  { league_id: nil, stat_type: 'PointsAllowed', min_range: 14, max_range: 20, fixed_points: 4 },
  { league_id: nil, stat_type: 'PointsAllowed', min_range: 21, max_range: 27, fixed_points: 2 },
  { league_id: nil, stat_type: 'OpponentOffensiveYards', min_range: 0, max_range: 49, fixed_points: 12 },
  { league_id: nil, stat_type: 'OpponentOffensiveYards', min_range: 50, max_range: 99, fixed_points: 10 },
  { league_id: nil, stat_type: 'OpponentOffensiveYards', min_range: 100, max_range: 149, fixed_points: 8 },
  { league_id: nil, stat_type: 'OpponentOffensiveYards', min_range: 150, max_range: 199, fixed_points: 6 },
  { league_id: nil, stat_type: 'OpponentOffensiveYards', min_range: 200, max_range: 249, fixed_points: 4 },
  { league_id: nil, stat_type: 'OpponentOffensiveYards', min_range: 250, max_range: 299, fixed_points: 2 },
]
rules.each do |data|
  data[:multiplier] = 0 unless data[:multiplier]
  data[:min_range] = 0 unless data[:min_range]
  data[:max_range] = 0 unless data[:max_range]
  data[:fixed_points] = 0 unless data[:fixed_points]
  stat_type = @stat_types[data[:stat_type]]

  rule = LeaguePointRule.find_or_create_by(stat_type_id: stat_type.id, min_range: data[:min_range], max_range: data[:max_range])
  rule.multiplier = data[:multiplier]
  rule.fixed_points = data[:fixed_points]
  rule.save
end

puts 'Seeding PayoutTypes'
payout_types = [
    { name: 'standing', display_name: 'Final League Standing' },
    { name: 'points', display_name: 'Final Points Rank' },
    { name: 'weekly_points', display_name: 'Weekly Points Rank' },
    { name: 'perfect_jackpot', display_name: 'Perfect Season' },
    { name: 'multi_league', display_name: 'Multi League Tournament' },
]
payout_types.each do |data|
  item = PayoutType.find_or_create_by(name: data[:name])
  item.display_name = data[:display_name]
  item.save
end

puts 'Seeding PayoutStructures'
payout_structures = [
    { name: 'standings', display_name: 'Traditional',
        values: [
            { payout_type: 'standing', rank: 1, percent: 0.68, display_name: 'Final Winner' },
            { payout_type: 'standing', rank: 2, percent: 0.16, display_name: 'Final Runner-Up' },
            { payout_type: 'points', rank: 1, percent: 0.16, display_name: 'Overall Points Leader' },
        ]
    },
    { name: 'standings_and_points', display_name: 'Team Standings and Top Points Structure',
        values: [
            { payout_type: 'standing', rank: 1, percent: 0.4, display_name: 'Final Winner' },
            { payout_type: 'standing', rank: 2, percent: 0.2, display_name: 'Final Runner-Up' },
            { payout_type: 'standing', rank: 3, percent: 0.05, display_name: 'Semi-Final Runner-Up 1' },
            { payout_type: 'standing', rank: 4, percent: 0.05, display_name: 'Semi-Final Runner-Up 2' },
            { payout_type: 'points', rank: 1, percent: 0.2, display_name: 'Overall Points Leader' },
            { payout_type: 'points', rank: 2, percent: 0.1, display_name: 'Overall Points Runner-Up' },
        ]
    },
    { name: 'points_only', display_name: 'Top Points Structure',
        values: [
            { payout_type: 'points', rank: 1, percent: 0.5, display_name: 'Overall Points Leader' },
            { payout_type: 'points', rank: 2, percent: 0.3, display_name: 'Overall Points Runner-Up' },
            { payout_type: 'points', rank: 3, percent: 0.2, display_name: 'Overall Points Third Place' },
        ]
    },
    { name: 'child_league', display_name: 'Satellite into Tournament',
      values: [
          { payout_type: 'standing', rank: 1, percent: 0.1, display_name: 'Satellite Winner' },
          { payout_type: 'multi_league', rank: 1, percent: 0.9, display_name: 'Carryover into Master' },
      ]
    },
    { name: 'master_league', display_name: 'Tournament',
      values: [
          { payout_type: 'points', rank: 1, percent: 0.5, display_name: 'Overall Points Leader' },
          { payout_type: 'points', rank: 2, percent: 0.3, display_name: 'Overall Points Runner-Up' },
          { payout_type: 'points', rank: 3, percent: 0.2, display_name: 'Overall Points Third Place' },
      ]
    },
]
payout_structures.each do |data|
  item = PayoutStructure.find_or_create_by(name: data[:name])
  item.display_name = data[:display_name]
  item.save

  item.payouts.destroy_all
  data[:values].each do |value|
    payout = PayoutStructurePayout.new
    payout.payout_structure_id = item.id
    payout.payout_type_id = PayoutType.find_by!(name: value[:payout_type]).id
    payout.rank = value[:rank]
    payout.percent = value[:percent]
    payout.display_name = value[:display_name]
    payout.save
  end
end
