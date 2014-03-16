FactoryGirl.define do
  factory :league do

    ignore do
      number_of_teams 12
    end

    size { number_of_teams }
    name { generate(:random_name) }
    league_type_id [1, 2, 3].sample
    entry_amount [25.00, 50.00, 100.00, 150.00].sample
    fee_percent 0.20
    draft_start_date Random.rand(90).days.from_now
    is_private false
    weeks 13

    after(:build) do |league, evaluator|
      create_list(:team, evaluator.number_of_teams, league: league)
      league.reload if league.id
    end

    factory :empty_league do
      ignore do
        number_of_teams 0
      end
      size 12
    end

    factory :partially_filled_league do
      ignore do
        number_of_teams 11
      end
      size 12
    end

    factory :draft_started_league do
      draft_start_date Random.rand(90).days.ago
    end

    factory :partially_filled_drafted_league do
      ignore do
        number_of_teams 11
      end
      size 12
      draft_start_date Random.rand(90).days.ago
    end
  end

  factory :team do
    name { generate(:random_name) }
    user
  end

  factory :user do
    email { generate(:random_email) }
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    address Faker::Address.street_address
    city Faker::Address.city
    state Faker::Address.state_abbr
    zip Faker::Address.zip_code
    password "a"*6
    password_confirmation "a"*6
  end

  sequence :random_name do |n|
    "#{n}_#{Faker::Name.title}"
  end

  sequence :random_email do |n|
    "#{n}_#{Faker::Internet.email}"
  end
end