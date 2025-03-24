Feature: Display available trees

  Scenario: User sees the list of available trees
    Given I am on the garden screen
    Then I see a list of trees including:
      | Oliveira  | 30 drops |
      | Palmeira  | 45 drops |
      | Carvalho  | 60 drops |
      | Pinheiro  | 80 drops |