Feature: Exit the app

  Scenario: User exits the app
    Given I am on the home screen
    When I tap the exit button
    And I confirm the exit
    Then the app closes