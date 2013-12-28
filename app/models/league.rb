class League < ActiveRecord::Base
  has_many :teams
  has_many :users, :through => :teams
  has_one :schedule

  attr_accessor :weeks

  validates :name, :uniqueness => { :case_sensitive => false }

  def available_teams
    self.size - self.teams_count
  end

  def create_schedule
    if league_full?
      game_values = (1..self.size).to_a
      @weeks = []
      (self.size - 1).times do |week_index| #unique weeks = league size - 1
        games = []
        games[0] = 1

        (self.size - 1).times do |game_index|
          self.size.times do |valid_index|
            team_two = game_values[(week_index + (game_index + 2) + valid_index) % self.size ]
            if is_game_valid?((game_index + 1),team_two,games)
              games[game_index + 1] = team_two
              break
            end
          end
        end
        @weeks.push(games)
      end

      (13 - (self.size - 1)).times do |remaining_week_index|
        @weeks.push (@weeks[remaining_week_index]).reverse
      end
    end
  end

  def league_full?
    available_teams == 0
  end

  def is_game_valid?(slot, team, games)
    !@weeks.find { |past_games| past_games[slot] == team } && !games.include?(team)
  end
end
