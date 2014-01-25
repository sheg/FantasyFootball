Feature: League Varieties
  The following describes the varieties of leagues a user may join,
  characterizing league attributes that may or not apply.

  Background:
    Given a league is available and all league attributes exist in the database

  Scenario: Traditional with playoffs
    When I join a traditional playoff league
    Then the league should be set with the following attributes:

    | size | name | fee | rule_set |


  Scenario: Traditional without playoffs
    When I join a traditional non playoff league
    Then the league should be set with the following attributes:

      | size | name | fee | rule_set |


  Scenario: Weekly
