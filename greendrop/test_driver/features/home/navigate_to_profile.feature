Feature: Navigate to the profile page

  Scenario: User navigates to the profile page
    Given I am on the home screen
    When I tap the profile icon
    Then I am taken to the profile page
    And I see my profile information