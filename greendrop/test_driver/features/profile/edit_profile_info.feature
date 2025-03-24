Feature: Edit profile information

  Scenario: User edits their profile information
    Given I am on the profile page
    When I tap the "Edit Profile" button
    And I change my profile picture
    And I change my name to "Jane Doe"
    And I change my email to "jane@gmail.com"
    And I change my location to "Lisbon, PT"
    And I save the changes
    Then I see the new profile picture displayed
    And I see my name as "Jane Doe"
    And I see my email as "jane@gmail.com"
    And I see my location as "Lisbon, PT"