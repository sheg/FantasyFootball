class Schedule < ActiveRecord::Base
  belongs_to :league
  belongs_to :game

end