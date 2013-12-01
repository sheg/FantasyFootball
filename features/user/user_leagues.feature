Feature: My League List
  As a registered user
  I would like to access all the leagues I am currently in
  So that I can view and manage them

  Scenario: View all users leagues

  Scenario: View league information
    Given I am on the My Leagues section
    When I select any registered league
    Then I should see the following information:

    | visibility | duration | type | league size | format | slots filled |