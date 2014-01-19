Feature: League Varieties
  The following describes the varieties of leagues a user may join,
  characterizing league attributes that may or not apply.

  Background:
    Given a league is available and all league attributes exist in the database

  Scenario: Traditional
    When I join a traditional league
    Then the league should be set with the following attributes:

    | size | name | fee | ...


  Scenario: Weekly
