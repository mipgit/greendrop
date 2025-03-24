Feature: Reset progress

  Scenario: User resets their progress
    Given I am on the home screen
    And I have completed some tasks
    And I have used some droplets
    When I tap the refresh button
    And I confirm the reset
    Then all tasks are marked as incomplete
    And the droplet count is reset to 30
    And the tree is marked as not grown