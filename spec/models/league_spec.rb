require 'spec_helper'

describe League do
  include LeaguesHelper

  before :each do
    @league = FactoryGirl.build :empty_league
  end

  after :each do
    League.destroy_all
  end

  subject { @league }

  it { should be_valid }
  it { should respond_to(:name) }
  it { should respond_to(:season_id)}
  it { should respond_to(:size)}
  it { should respond_to(:teams_count)}
  it { should respond_to(:weeks)}
  it { should respond_to(:league_type)}
  it { should respond_to(:entry_amount)}
  it { should respond_to(:fee_percent)}
  it { should respond_to(:roster_count)}
  it { should respond_to(:playoff_weeks)}
  it { should respond_to(:teams_in_playoffs)}
  it { should respond_to(:draft_start_date) }
  it { should respond_to(:is_private)}

  describe "when league name is already taken" do
    before do
      duplicate_league = @league.dup
      duplicate_league.save
    end
    it { should_not be_valid }
  end

  describe "when I look for a new user just added to a league" do
    before do
      @league = FactoryGirl.create :partially_filled_league
      @user = FactoryGirl.create :user
      join_league(@league, @user)
    end

    it "should be found" do
      @league.user_part_of_league?(@user).should be_true
    end
  end

  describe "when a user is not part of a league" do
    before { @user = FactoryGirl.create :user }
    it "should NOT be found" do
      @league.user_part_of_league?(@user).should be_false
    end
  end

  describe "when league has no open teams" do
    before do
      @league = FactoryGirl.create :league
    end
    it { should be_full }
  end

  describe "when league has open teams" do
    before do
      @league = FactoryGirl.create :partially_filled_league
    end
    it { should_not be_full }
  end

  describe "scopes" do
    describe "when no leagues are filled" do
      before do
        League.destroy_all
        @league.save!
      end

      it "full scope should return empty" do
        League.full.should be_empty
      end

      it "open scope should return an open league" do
        League.open.should include @league
      end
    end

    describe "when there is a filled league" do
      before do
        League.destroy_all
        @filled_league = FactoryGirl.create :league
      end

      it "full scope should return the filled league" do
        League.full.should include @filled_league
      end

      it "open scope should return empty" do
        League.open.should be_empty
      end
    end
  end

  describe "draft started" do
    describe "when the league is full" do
      it "should show up as started" do
        league = FactoryGirl.create :draft_started_league
        league.started?.should be_true
      end
    end

    describe "when the league not full" do
      it "should show up as not started" do
        league = FactoryGirl.create :partially_filled_drafted_league
        league.started?.should be_false
      end
    end
  end

  describe "draft did not start yet" do
    describe "when the league is full" do
      it "should show up as not started" do
        league = FactoryGirl.create :league
        league.started?.should be_false
      end
    end

    describe "when the league not full" do
      it "should show up as not started" do
        league = FactoryGirl.create :partially_filled_league
        league.started?.should be_false
      end
    end
  end

  describe "fully drafted league in preason" do
    before do
      @league = FactoryGirl.create :draft_started_league
      @league.draft_start_date = Date.new(2013,8,16)
      @league.save!
      @league.test_draft
      @league = League.find(@league.id)
    end

    it "nfl start week should be set to one" do
      @league.nfl_start_week.should_not be_nil
      @league.nfl_start_week.should == 1
    end

    it "should have a populated start_week_date" do
      @league.start_week_date.should_not be_nil
      @league.start_week_date.should == Date.new(2013,9,3)
      @league.start_week_date.wday.should == 2
    end
  end

  describe "fully drafted league before preseason" do
    before do
      @league = FactoryGirl.create :draft_started_league
      @league.draft_start_date = Date.new(2013,5,15)
      @league.save!
      @league.test_draft
      @league = League.find(@league.id)
    end

    it "nfl start week should be set to one" do
      @league.nfl_start_week.should_not be_nil
      @league.nfl_start_week.should == 1
    end

    it "should have a populated start_week_date" do
      @league.start_week_date.should_not be_nil
      @league.start_week_date.should == Date.new(2013,9,3)
    end
  end

  describe "fully drafted league in the middle of the season" do
    before do
      @league = FactoryGirl.create :league
      @league.draft_start_date = Date.new(2013,10,16)
      @league.save!
      @league.test_draft
      @league = League.find(@league.id)
    end

    it "nfl start week should be set to it's appropriate start date" do
      @league.nfl_start_week.should_not be_nil
      @league.nfl_start_week.should == 8
    end

    it "should have a populated start_week_date" do
      @league.start_week_date.should_not be_nil
      @league.start_week_date.should == Date.new(2013,10,22)
    end
  end

  describe "fully drafted league on a monday during the season" do
    before do
      @league = FactoryGirl.create :league
      @league.draft_start_date = Date.new(2013,10,14)
      @league.save!
      @league.test_draft
      @league = League.find(@league.id)
    end

    it "nfl start week should be set to appropriate start date" do
      @league.nfl_start_week.should_not be_nil
      @league.nfl_start_week.should == 7
    end

    it "should have a populated start_week_date for the following Tuesday" do
      @league.start_week_date.should_not be_nil
      @league.start_week_date.should == Date.new(2013,10,15)
    end
  end

  describe "visibility" do
    describe "league is set to private" do
      before do
        @league = FactoryGirl.create(:league, is_private: true)
      end

      it "should be private" do
        @league.is_private.should be_true
      end
    end

    describe "league is set to public" do
      before do
        @league = FactoryGirl.create(:league, is_private: false)
      end

      it "should not be private" do
        @league.is_private.should be_false
      end
    end
  end
end