# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131128075631) do

  create_table "activity_types", force: true do |t|
    t.string   "name"
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_rosters", force: true do |t|
    t.integer  "game_id"
    t.integer  "roster_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: true do |t|
    t.integer  "week"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "home_score"
    t.integer  "away_score"
    t.datetime "game_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leagues", force: true do |t|
    t.integer  "season_id"
    t.string   "name"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leagues", ["season_id"], name: "index_leagues_on_season_id"

  create_table "nfl_game_stats", force: true do |t|
    t.integer  "nfl_game_id"
    t.integer  "nfl_player_id"
    t.integer  "passing_yards"
    t.integer  "interceptions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nfl_games", force: true do |t|
    t.integer  "week"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.datetime "start_time"
    t.integer  "home_score"
    t.integer  "away_score"
    t.integer  "quarter"
    t.boolean  "posession"
    t.integer  "down"
    t.integer  "yards_to_go"
    t.integer  "yardline"
    t.boolean  "field_side"
    t.datetime "time_remaining"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nfl_games", ["away_team_id"], name: "index_nfl_games_on_away_team_id"
  add_index "nfl_games", ["home_team_id"], name: "index_nfl_games_on_home_team_id"

  create_table "nfl_players", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nfl_positions", force: true do |t|
    t.string   "name"
    t.string   "abbr"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nfl_season_team_players", force: true do |t|
    t.integer  "season_id"
    t.integer  "team_id"
    t.integer  "player_id"
    t.integer  "position_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nfl_seasons", force: true do |t|
    t.integer  "year"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nfl_teams", force: true do |t|
    t.string   "name"
    t.string   "abbr"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roster_activities", force: true do |t|
    t.integer  "roster_id"
    t.integer  "activity_type_id"
    t.datetime "activity_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rosters", force: true do |t|
    t.integer  "league_team_id"
    t.integer  "nfl_player_id"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: true do |t|
    t.integer  "league_id"
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["league_id"], name: "index_teams_on_league_id"
  add_index "teams", ["user_id"], name: "index_teams_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email"

end
