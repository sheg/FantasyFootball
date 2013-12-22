class LeaguesController < ApplicationController

  def index
    @leagues = League.all
  end

  def show
    @league = League.find(params[:id])
  end

  def new
  end

  def create
  end
end