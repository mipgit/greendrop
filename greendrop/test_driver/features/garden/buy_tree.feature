Feature: Buy a tree

  Scenario: User buys a tree successfully
    Given I am on the garden screen
    And I have 50 drops
    When I tap on the "Oliveira" tree
    And I confirm the purchase
    Then the tree "Oliveira" is marked as bought
    And my coin balance decreases by 30

  Scenario: User tries to buy a tree without enough coins
    Given I am on the garden screen
    And I have 20 coins
    When I tap on the "Palmeira" tree
    Then I see a message "You don't have enough coins to buy this tree."