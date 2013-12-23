class CreateStatTypes < ActiveRecord::Migration
  def up
    create_table :stat_types do |t|
      t.string :name
      t.string :group
      t.string :abbr
      t.string :display_name

      t.timestamps
    end

    add_index :stat_types, :name

    StatType.create(name: "PassingAttempts", group: 'Passing', abbr: 'Att', display_name: 'Passing Attempts')
    StatType.create(name: "PassingCompletions", group: 'Passing', abbr: 'Comp', display_name: 'Passing Completions')
    StatType.create(name: "PassingCompletionPercentage", group: 'Passing', abbr: 'Pct', display_name: 'Passing Completion %')
    StatType.create(name: "PassingYards", group: 'Passing', abbr: 'Yds', display_name: 'Passing Yards')
    StatType.create(name: "PassingYardsPerAttempt", group: 'Passing', abbr: 'AvgA', display_name: 'Passing Yards Per Attempt')
    StatType.create(name: "PassingYardsPerCompletion", group: 'Passing', abbr: 'AvgC', display_name: 'Passing Yards Per Completion')
    StatType.create(name: "PassingTouchdowns", group: 'Passing', abbr: 'TD', display_name: 'Passing Touchdowns')
    StatType.create(name: "PassingInterceptions", group: 'Passing', abbr: 'Int', display_name: 'Passing Interceptions')
    StatType.create(name: "PassingRating", group: 'Passing', abbr: 'Rate', display_name: 'Passing Rating')
    StatType.create(name: "PassingSacks", group: 'Passing', abbr: 'Sac', display_name: 'Passing Sacks')
    StatType.create(name: "PassingSackYards", group: 'Passing', abbr: 'Yds', display_name: 'Passing Sack Yards')
    StatType.create(name: "TwoPointConversionPasses", group: 'Passing', abbr: '2Pt', display_name: 'Passing Two Point Conversions')
    StatType.create(name: "PassingLong", group: 'Passing', abbr: 'Lg', display_name: 'Passing Longest')

    StatType.create(name: "ReceivingTargets", group: 'Receiving', abbr: 'Att', display_name: 'Targets')
    StatType.create(name: "Receptions", group: 'Receiving', abbr: 'Rec', display_name: 'Receptions')
    StatType.create(name: "ReceptionPercentage", group: 'Receiving', abbr: 'Pct', display_name: 'Reception %')
    StatType.create(name: "ReceivingYards", group: 'Receiving', abbr: 'Yds', display_name: 'Yards')
    StatType.create(name: "ReceivingYardsPerTarget", group: 'Receiving', abbr: 'AvgT', display_name: 'Yards Per Target')
    StatType.create(name: "ReceivingYardsPerReception", group: 'Receiving', abbr: 'AvgR', display_name: 'Yards Per Reception')
    StatType.create(name: "ReceivingTouchdowns", group: 'Receiving', abbr: 'TD', display_name: 'Touchdowns')
    StatType.create(name: "ReceivingLong", group: 'Receiving', abbr: 'Lg', display_name: 'Longest')
    StatType.create(name: "TwoPointConversionReceptions", group: 'Receiving', abbr: '2Pt', display_name: 'Two Point Conversions')

    StatType.create(name: "RushingAttempts", group: 'Rushing', abbr: 'Att', display_name: 'Attempts')
    StatType.create(name: "RushingYards", group: 'Rushing', abbr: 'Yds', display_name: 'Yards')
    StatType.create(name: "RushingYardsPerAttempt", group: 'Rushing', abbr: 'Avg', display_name: 'Yards Per Attempt')
    StatType.create(name: "RushingTouchdowns", group: 'Rushing', abbr: 'TD', display_name: 'Touchdowns')
    StatType.create(name: "RushingLong", group: 'Rushing', abbr: 'Lg', display_name: 'Longest')
    StatType.create(name: "TwoPointConversionRuns", group: 'Rushing', abbr: '2Pt', display_name: 'Two Point Conversions')

    StatType.create(name: "FumblesLost", group: 'Fumbles', abbr: 'Fum', display_name: 'Lost')
    StatType.create(name: "FumblesRecovered", group: 'Fumbles', abbr: 'Rec', display_name: 'Recovered')
    StatType.create(name: "FumbleReturnYards", group: 'Fumbles', abbr: 'Yds', display_name: 'Return Yards')
    StatType.create(name: "FumbleReturnTouchdowns", group: 'Fumbles', abbr: 'TD', display_name: 'Return Touchdowns')

    StatType.create(name: "Interceptions", group: 'Defense', abbr: '', display_name: 'Interceptions')
    StatType.create(name: "Sacks", group: 'Defense', abbr: '', display_name: 'Sacks')
    StatType.create(name: "Safeties", group: 'Defense', abbr: '', display_name: 'Safeties')
    StatType.create(name: "DefensiveTouchdowns", group: 'Defense', abbr: '', display_name: 'Touchdowns')

    StatType.create(name: "ExtraPointsMade", group: 'Scoring', abbr: 'XP', display_name: 'Extra Points')
    StatType.create(name: "FieldGoalsMade", group: 'Field Goals', abbr: 'FG', display_name: 'Field Goals')
  end

  def down
    drop_table :stat_types
  end
end
