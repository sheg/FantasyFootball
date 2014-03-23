require 'spec_helper'

describe LeaguesController, type: :controller do
  before do
    League.destroy_all
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      response.should be_success
    end

    it "populates an array of leagues" do
      league = FactoryGirl.create :league
      get :index
      assigns(:leagues).should eq([league])
    end

    context "when not signed in" do
      it "user leagues should not show up" do
        assigns(:user_leagues).should be_nil
      end
    end
  end

  describe "GET #show" do
    context "when a league exists" do
      it "should not be able to show a league user does not belong to" do
        league = FactoryGirl.create :league
        get :show, league_id: league.id
        assigns(:league).should be_nil
      end
    end
  end
end
