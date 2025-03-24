Feature: Navigate to tree details

  Scenario: User navigates to the details of a tree
    Given I am on the garden screen
    When I tap on the "Oliveira" tree
    Then I am taken to the tree details screen
    And I see the details of the "Oliveira" tree