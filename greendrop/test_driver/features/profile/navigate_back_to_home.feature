Feature: Navigate back to home

  Scenario: User navigates back to the home page
    Given I am on the profile page
    When I tap the back button
    Then I am taken to the home page