class CreateStatTypes < ActiveRecord::Migration
  def up
    create_table :stat_types do |t|
      t.string :name
      t.string :group
      t.string :abbr
      t.string :display_name

      t.timestamps
    end

    add_index :stat_types, :name, unique: true
  end

  def down
    drop_table :stat_types
  end
end
