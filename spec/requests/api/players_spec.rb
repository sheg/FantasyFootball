require 'spec_helper'

describe "Players API" do

  before(:each) do
    host! 'api.pointsleaders-dev.com'
  end

  describe "GET #index" do

    it 'should retrieve all available players' do
      get 'v1/players'
      response.should be_success
      puts response.body
    end
  end
end