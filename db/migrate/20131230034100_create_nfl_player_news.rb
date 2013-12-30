class CreateNflPlayerNews < ActiveRecord::Migration
  def change
    create_table :nfl_player_news do |t|
      t.integer :nfl_player_id
      t.string :headline, limit: 500
      t.string :body, limit: 2000
      t.string :source
      t.string :url, limit: 500
      t.string :terms, limit: 2000
      t.datetime :news_date
      t.integer :external_news_id

      t.timestamps
    end

    add_index :nfl_player_news, [ :nfl_player_id, :external_news_id ]
  end
end
