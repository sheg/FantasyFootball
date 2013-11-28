Feature: My Friends List
  As a registered user
  I would like to keep track of my friends
  So that I can invite friends to join a league or send them a message

  Scenario: send a friend a message

  Scenario Outline: successfully invite a friend to join a league
    Given I am on the friends list page
    And a non filled up "<league_type>" league that is "<accessibility>" is available
    When I invite a friend to join the league
    Then the friend should get an email notification to join

  Examples:

  | league_type | accessibility |
  |  free       |   private     |
  |  mock       |   private     |
  |  paid       |   private     |
  |  free       |   public      |
  |  mock       |   public      |
  |  paid       |   public      |