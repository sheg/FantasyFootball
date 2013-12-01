Feature: New League Creation
  As a registered user
  I would like to create a new league
  So that users can join and play fantasy football

  Possible league categories:
  - visibility: public or private
  - duration: weekly or tradition, playoffs?
  - type: mock, free or paid
  - league size
  - format (normal, flex, custom?)

  Possible TRADITIONAL league customizations:
  - League Name (optional)
  - Type (mock, free, or paid)
  - League Size (10, 12, 14)
  - Visibility (public, private)
  - Format (normal, flex, custom?)
  - (if type = paid):
      Prize Structure (2 - 3, 4 - 5)
      Entry Fee

  Possible WEEKLY league customizations:
  - League Name (optional)
  - Type (Free or Paid)
  - Entry Fee (if type = paid)
  - League Size (2 - 12)
  - Visibility (public or private)
  - (if type = paid):
      Prize Structure
      Entry Fee


  Scenario: Invite others to join new league upon creation via email