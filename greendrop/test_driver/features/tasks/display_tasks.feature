Feature: Display daily eco tasks

  Scenario: User sees the list of daily eco tasks
    Given I am on the tasks screen
    Then I see a list of tasks including:
      | Use a reusable water bottle.       |
      | Turn off lights when not in use.   |
      | Recycle paper and plastics.        |
      | Use public transportation or bike. |
      | Reduce food waste.                 |