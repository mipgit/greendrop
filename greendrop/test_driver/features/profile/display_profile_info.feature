Feature: Display profile information

  Scenario: User sees their profile information
    Given I am on the profile page
    Then I see my profile picture
    And I see my name as "John Doe"
    And I see my email as "john@gmail.com"
    And I see my location as "Porto, PT"