#0 1,2,3,4
#1 1,3,2,4
#2 1,4,2,3

#3 1,2,3,4



class Schedule
  def initiate_schedule
    game_values = [1,2,3,4,5,6,7,8,9,10,11,12]
    @weeks = []
    11.times do |week_index|
      games = []
      games[0] = 1

      11.times do |game_index|
        12.times do |valid_index|
          team_two = game_values[(week_index + (game_index + 2) + valid_index) % 12 ]
          if is_valid?((game_index + 1),team_two,games)
            games[game_index + 1] = team_two
            break
          end
        end
      end


      #4.times do |valid_index|
      #  team_two = game_values[(week_index + 2 + valid_index) % 4 ]
      #  if is_valid?(1,team_two,games)
      #    games[1] = team_two
      #    break
      #  end
      #end
      #
      #4.times do |valid_index|
      #  team_three = game_values[(week_index + 3 + valid_index) % 4 ]
      #  if is_valid?(2,team_three,games)
      #    games[2] = team_three
      #    break
      #  end
      #end
      #
      #4.times do |valid_index|
      #  team_four = game_values[(week_index + 4 + valid_index) % 4 ]
      #  if is_valid?(3,team_four,games)
      #    games[3] = team_four
      #    break
      #  end
      #end

      @weeks.push(games)
    end

    2.times do |remaining_week_index|
      @weeks.push (@weeks[remaining_week_index]).reverse
    end
    puts @weeks.inspect
end

  def is_valid?(slot, team, games)
    !@weeks.find { |past_games| past_games[slot] == team } && !games.include?(team)
  end
end

schedule = Schedule.new
schedule.initiate_schedule



#team_two = g_values[(week_index + 2) % 4 ]
#if is_valid?(weeks,1,team_two,games)
#  games[1] == team_two
#else
#  team_two = g_values[(week_index + 2 + 1) % 4 ]
#  if is_valid?(weeks,1,team_two,games)
#    games[1] == team_two
#  else
#    team_two = g_values[(week_index + 2 + 2) % 4 ]
#    if is_valid?(weeks,1,team_two,games)
#      games[1] == team_two
#    else
#      team_two = g_values[(week_index + 2 + 3) % 4 ]
#      games[1] == team_two
#    end
#  end
#end
#
#team_three = g_values[(week_index + 3) % 4 ]
#if is_valid?(weeks,2,team_three,games)
#  games[2] == team_three
#else
#  team_three = g_values[(week_index + 3 + 1) % 4 ]
#  if is_valid?(weeks,2,team_three,games)
#    games[2] == team_three
#  else
#    team_three = g_values[(week_index + 3 + 2) % 4 ]
#    if is_valid?(weeks,2,team_three,games)
#      games[2] == team_three
#    else
#      team_three = g_values[(week_index + 3 + 3) % 4 ]
#      games[2] == team_three
#    end
#  end
#end
#
#team_four = g_values[(week_index + 4) % 4 ]
#if is_valid?(weeks,3,team_four,games)
#  games[3] == team_four
#else
#  team_four = g_values[(week_index + 4 + 1) % 4 ]
#  if is_valid?(weeks,3,team_four,games)
#    games[3] == team_four
#  else
#    team_four = g_values[(week_index + 4 + 2) % 4 ]
#    if is_valid?(weeks,3,team_four,games)
#      games[3] == team_four
#    else
#      team_four = g_values[(week_index + 4 + 3) % 4 ]
#      games[3] == team_four
#    end
#  end
#end