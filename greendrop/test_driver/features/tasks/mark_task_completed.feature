Feature: Mark a task as completed

  Scenario: User marks a task as completed
    Given I am on the tasks screen
    And the task "Use a reusable water bottle." is not completed
    When I mark the task "Use a reusable water bottle." as completed
    Then the task "Use a reusable water bottle." is marked as completed
    And the droplet count increases by 1