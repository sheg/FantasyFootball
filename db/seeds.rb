# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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
