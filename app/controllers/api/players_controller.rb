module Api
  class PlayersController < ApplicationController

    def index
      nfl_players = NflGamePlayer.includes([:player, :team, :position]).all.limit(30)
      render json: nfl_players.to_json(:include => [{ :player => { :only => [:first_name, :last_name] }},
                                                      :team => { :only => [:name, :abbr]},
                                                      :position => { :only => :abbr }]), status: :ok
    end
  end
end