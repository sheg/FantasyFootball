require 'spec_helper'

describe League do
  include LeaguesHelper

  before :each do
    @user = User.new(email: "test@test.com", password: "asdqwe",
                                               password_confirmation: "asdqwe" )

    @league = League.new(name: "test_league #{Random.rand(10000)}",size: 12,
                         weeks: 13, start_week_date: 2.days.from_now)
  end

  after  { @league = nil }

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

  describe "when league name is already taken" do
    before do
      duplicate_league = @league.dup
      duplicate_league.save
    end
    it { should_not be_valid }
  end

  describe "when I look for a new user just added to a league" do
    before do
      @league.save!
      @user.save!
      join_league(@league, @user)
    end

    it "should be found" do
      @league.user_part_of_league?(@user).should be_true
    end
  end

  describe "when a user is not part of a league" do
    it "should NOT be found" do
      @league.user_part_of_league?(@user).should be_false
    end
  end

  describe "when league has no open teams" do
    before do
      size = @league.size
      @league = create_league(size)
    end
    it { should be_full }
  end

  describe "when league has open teams" do
    before do
      size = @league.size
      @league = create_league(size, 2)
    end
    it { should_not be_full }
  end

  describe "scopes" do
    describe "when no leagues are filled" do
      before do
        @league.save!
      end

      it "full scope should return empty" do
        League.full.should be_empty
      end

      it "open scope should return an open league" do
        League.open.should include @league
      end
    end

    describe "when there is a filled up league" do
      before do
        @filled_league = create_league(10, 0)
      end

      it "full scope should return the filled league" do
        League.full.should include @filled_league
      end

      it "open scope should return empty" do
        League.open.should be_empty
      end
    end
  end
end