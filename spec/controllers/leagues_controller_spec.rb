require 'spec_helper'

describe LeaguesController, type: :controller do

  describe "GET #index'" do
    before do
      League.destroy_all
    end

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

    context "when user is signed in" do
      pending
    end
  end
end
