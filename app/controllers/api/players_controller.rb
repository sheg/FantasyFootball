module Api
  class PlayersController < ApplicationController

    def index
      nfl_players = NflGamePlayer.all
      render json: nfl_players, status: :ok
    end
  end
end