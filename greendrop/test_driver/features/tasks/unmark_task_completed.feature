Feature: Unmark a task as completed

  Scenario: User unmarks a completed task
    Given I am on the tasks screen
    And the task "Turn off lights when not in use." is completed
    When I unmark the task "Turn off lights when not in use."
    Then the task "Turn off lights when not in use." is marked as not completed
    And the droplet count decreases by 1