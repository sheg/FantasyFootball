class LeaguesController < ApplicationController

  def index
    @leagues = League.all.includes(:teams)
  end

  def show
    @league = League.includes(:users).find_by(id: params[:id])
  end

  def new
  end

  def create
  end
end