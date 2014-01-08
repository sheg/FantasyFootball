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

puts 'Seeding Positions'
positions = [
  { abbr: "QB", name: 'Quarterback' },
  { abbr: "RB", name: 'Running Back' },
  { abbr: "WR", name: 'Wide Receiver' },
  { abbr: "TE", name: 'Tight End' },
  { abbr: "K", name: 'Kicker' },
  { abbr: "DST", name: 'Defense' },
]
positions.each do |data|
  position = NflPosition.find_or_create_by(abbr: data[:abbr])
  position.name = data[:name]
  position.save
end

puts 'Seeding StatTypes'
stat_types = [
  { name: "PassingAttempts", group: 'Passing', abbr: 'Att', display_name: 'Passing Attempts' },
  { name: "PassingCompletions", group: 'Passing', abbr: 'Comp', display_name: 'Passing Completions' },
  { name: "PassingCompletionPercentage", group: 'Passing', abbr: 'Pct', display_name: 'Passing Completion %' },
  { name: "PassingYards", group: 'Passing', abbr: 'Yds', display_name: 'Passing Yards' },
  { name: "PassingYardsPerAttempt", group: 'Passing', abbr: 'AvgA', display_name: 'Passing Yards Per Attempt' },
  { name: "PassingYardsPerCompletion", group: 'Passing', abbr: 'AvgC', display_name: 'Passing Yards Per Completion' },
  { name: "PassingTouchdowns", group: 'Passing', abbr: 'TD', display_name: 'Passing Touchdowns' },
  { name: "PassingInterceptions", group: 'Passing', abbr: 'Int', display_name: 'Passing Interceptions' },
  { name: "PassingRating", group: 'Passing', abbr: 'Rate', display_name: 'Passing Rating' },
  { name: "PassingSacks", group: 'Passing', abbr: 'Sac', display_name: 'Passing Sacks' },
  { name: "PassingSackYards", group: 'Passing', abbr: 'Yds', display_name: 'Passing Sack Yards' },
  { name: "TwoPointConversionPasses", group: 'Passing', abbr: '2Pt', display_name: 'Passing Two Point Conversions' },
  { name: "PassingLong", group: 'Passing', abbr: 'Lg', display_name: 'Passing Longest' },
  { name: "ReceivingTargets", group: 'Receiving', abbr: 'Att', display_name: 'Targets' },
  { name: "Receptions", group: 'Receiving', abbr: 'Rec', display_name: 'Receptions' },
  { name: "ReceptionPercentage", group: 'Receiving', abbr: 'Pct', display_name: 'Reception %' },
  { name: "ReceivingYards", group: 'Receiving', abbr: 'Yds', display_name: 'Yards' },
  { name: "ReceivingYardsPerTarget", group: 'Receiving', abbr: 'AvgT', display_name: 'Yards Per Target' },
  { name: "ReceivingYardsPerReception", group: 'Receiving', abbr: 'AvgR', display_name: 'Yards Per Reception' },
  { name: "ReceivingTouchdowns", group: 'Receiving', abbr: 'TD', display_name: 'Touchdowns' },
  { name: "ReceivingLong", group: 'Receiving', abbr: 'Lg', display_name: 'Longest' },
  { name: "TwoPointConversionReceptions", group: 'Receiving', abbr: '2Pt', display_name: 'Two Point Conversions' },
  { name: "RushingAttempts", group: 'Rushing', abbr: 'Att', display_name: 'Attempts' },
  { name: "RushingYards", group: 'Rushing', abbr: 'Yds', display_name: 'Yards' },
  { name: "RushingYardsPerAttempt", group: 'Rushing', abbr: 'Avg', display_name: 'Yards Per Attempt' },
  { name: "RushingTouchdowns", group: 'Rushing', abbr: 'TD', display_name: 'Touchdowns' },
  { name: "RushingLong", group: 'Rushing', abbr: 'Lg', display_name: 'Longest' },
  { name: "TwoPointConversionRuns", group: 'Rushing', abbr: '2Pt', display_name: 'Two Point Conversions' },
  { name: "FumblesLost", group: 'Fumbles', abbr: 'Fum', display_name: 'Lost' },
  { name: "FumblesRecovered", group: 'Fumbles', abbr: 'Rec', display_name: 'Recovered' },
  { name: "FumbleReturnYards", group: 'Fumbles', abbr: 'Yds', display_name: 'Return Yards' },
  { name: "FumbleReturnTouchdowns", group: 'Fumbles', abbr: 'TD', display_name: 'Return Touchdowns' },
  { name: "Interceptions", group: 'Defense', abbr: '', display_name: 'Interceptions' },
  { name: "InterceptionReturnYards", group: 'Defense', abbr: 'Yds', display_name: 'Interception Return Yards' },
  { name: "InterceptionReturnTouchdowns", group: 'Defense', abbr: 'TD', display_name: 'Interception Return Touchdowns' },
  { name: "Sacks", group: 'Defense', abbr: '', display_name: 'Sacks' },
  { name: "Safeties", group: 'Defense', abbr: '', display_name: 'Safeties' },
  { name: "DefensiveTouchdowns", group: 'Defense', abbr: '', display_name: 'Touchdowns' },
  { name: "PointsAllowed", group: 'Defense', abbr: 'PA', display_name: 'Points Allowed' },
  { name: "ExtraPointsMade", group: 'Scoring', abbr: 'XP', display_name: 'Extra Points' },
  { name: "FieldGoalsMade", group: 'Field Goals', abbr: 'FG', display_name: 'Field Goals' },
]
stat_types.each do |data|
  stat_type = StatType.find_or_create_by(name: data[:name])
  stat_type.group = data[:group]
  stat_type.abbr = data[:abbr]
  stat_type.display_name = data[:display_name]
  stat_type.save
end

=begin
puts 'Seeding PositionStats'
position_stats = [
    { position_id: NflPosition['QB'], stat_type_id: StatType['PassingAttempts'].id, sort_order: 10 },
    { position_id: NflPosition['QB'], stat_type_id: StatType['PassingYards'].id, sort_order: 20 },
    { position_id: NflPosition['QB'], stat_type_id: StatType['PassingInterceptions'].id, sort_order: 30 },
    { position_id: NflPosition['RB'], stat_type_id: StatType[''].id, sort_order: 10 },
    { position_id: NflPosition['RB'], stat_type_id: StatType[''].id, sort_order: 20 },
    { position_id: NflPosition['WR'], stat_type_id: StatType[''].id, sort_order: 10 },
    { position_id: NflPosition['WR'], stat_type_id: StatType[''].id, sort_order: 20 },
    { position_id: NflPosition['TE'], stat_type_id: StatType[''].id, sort_order: 10 },
    { position_id: NflPosition['TE'], stat_type_id: StatType[''].id, sort_order: 20 },
    { position_id: NflPosition['K'], stat_type_id: StatType[''].id, sort_order: 10 },
    { position_id: NflPosition['K'], stat_type_id: StatType[''].id, sort_order: 20 },
    { position_id: NflPosition['DST'], stat_type_id: StatType[''].id, sort_order: 10 },
    { position_id: NflPosition['DST'], stat_type_id: StatType[''].id, sort_order: 20 },
]
position_stats.each do |data|
  item = NflPositionStat.find_or_create_by(nfl_position_id: data[:position_id], stat_type_id: data[:stat_type_id])
  item.sort_order = data[:sort_order]
  item.save
end
=end

puts 'Seeding LeaguePointRules'
rules = [
  { league_id: nil, stat_type_id: StatType.find_by(name: 'FieldGoalsMade').id, multiplier: 3 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'FumblesLost').id, multiplier: -2 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'TwoPointConversionPasses').id, multiplier: 2 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'PassingInterceptions').id, multiplier: -2 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'PassingTouchdowns').id, multiplier: 6 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'PassingYards').id, multiplier: 0.04 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'TwoPointConversionReceptions').id, multiplier: 2 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'ReceivingTouchdowns').id, multiplier: 6 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'ReceivingYards').id, multiplier: 0.1 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'TwoPointConversionRuns').id, multiplier: 2 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'RushingTouchdowns').id, multiplier: 6 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'RushingYards').id, multiplier: 0.1 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'ExtraPointsMade').id, multiplier: 1 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'FumblesRecovered').id, multiplier: 2 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'DefensiveTouchdowns').id, multiplier: 6 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'Interceptions').id, multiplier: 2 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'Sacks').id, multiplier: 1 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'PointsAllowed').id, min_range: 0, max_range: 6, fixed_points: 8 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'PointsAllowed').id, min_range: 7, max_range: 13, fixed_points: 6 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'PointsAllowed').id, min_range: 14, max_range: 20, fixed_points: 4 },
  { league_id: nil, stat_type_id: StatType.find_by(name: 'PointsAllowed').id, min_range: 21, max_range: 27, fixed_points: 2 },
]
rules.each do |data|
  data[:multiplier] = 0 unless data[:multiplier]
  data[:min_range] = 0 unless data[:min_range]
  data[:max_range] = 0 unless data[:max_range]
  data[:fixed_points] = 0 unless data[:fixed_points]

  rule = LeaguePointRule.find_or_create_by(stat_type_id: data[:stat_type_id], min_range: data[:min_range], max_range: data[:max_range])
  rule.multiplier = data[:multiplier]
  rule.fixed_points = data[:fixed_points]
  rule.save
end

puts 'Seeding PayoutTypes'
payout_types = [
    { name: 'standing', display_name: 'Final League Standing' },
    { name: 'points', display_name: 'Final Points Rank' },
    { name: 'weekly_points', display_name: 'Weekly Points Rank' },
]
payout_types.each do |data|
  item = PayoutType.find_or_create_by(name: data[:name])
  item.display_name = data[:display_name]
  item.save
end

puts 'Seeding PayoutStructures'
payout_structures = [
    { name: 'standings', display_name: 'Team Standings Structure',
        values: [
            { payout_type: 'standing', rank: 1, percent: 0.5, display_name: 'Final Winner' },
            { payout_type: 'standing', rank: 2, percent: 0.3, display_name: 'Final Runner-Up' },
            { payout_type: 'standing', rank: 3, percent: 0.1, display_name: 'Semi-Final Runner-Up 1' },
            { payout_type: 'standing', rank: 4, percent: 0.1, display_name: 'Semi-Final Runner-Up 2' },
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
