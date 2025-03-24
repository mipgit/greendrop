Feature: Water the tree

  Scenario: User waters the tree successfully
    Given I am on the home screen
    When I tap the "Water Me!" button
    Then the droplet count decreases by 1

  Scenario: User tries to water the tree with no droplets
    Given I am on the home screen
    And I have 0 droplets
    When I tap the "Water Me!" button
    Then I see a snackbar with the message "You don't have any droplets!"