class CreateLeaguePointRules < ActiveRecord::Migration
  def up
    create_table :league_point_rules do |t|
      t.integer :league_id
      t.integer :stat_type_id
      t.decimal :multiplier, precision: 10, scale: 4

      t.timestamps
    end

    add_index :league_point_rules, [ :league_id, :stat_type_id ], unique: true

    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'FieldGoalsMade').id, multiplier: 3)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'FumblesLost').id, multiplier: -2)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'TwoPointConversionPasses').id, multiplier: 2)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'PassingInterceptions').id, multiplier: -2)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'PassingTouchdowns').id, multiplier: 6)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'PassingYards').id, multiplier: 0.04)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'TwoPointConversionReceptions').id, multiplier: 2)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'ReceivingTouchdowns').id, multiplier: 6)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'ReceivingYards').id, multiplier: 0.1)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'TwoPointConversionRuns').id, multiplier: 2)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'RushingTouchdowns').id, multiplier: 6)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'RushingYards').id, multiplier: 0.1)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'ExtraPointsMade').id, multiplier: 1)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'FumblesRecovered').id, multiplier: 2)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'DefensiveTouchdowns').id, multiplier: 6)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'Interceptions').id, multiplier: 2)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'Sacks').id, multiplier: 1)
    LeaguePointRule.create(league_id: nil, stat_type_id: StatType.find_by(name: 'Safeties').id, multiplier: 2)
  end

  def down
     drop_table :league_point_rules
  end
end
