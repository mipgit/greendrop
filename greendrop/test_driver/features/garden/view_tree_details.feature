Feature: View tree details

  Scenario: User views details of a tree
    Given I am on the garden screen
    When I tap on the "Carvalho" tree
    Then I see a dialog with the following details:
      | Name        | Carvalho         |
      | Price       | 60 drops         |
      | Description | A strong, durable tree known for its hardwood. |