Feature: User Login

  Scenario: Successful login
    Given I am on the login screen
    When I enter valid credentials
    And I tap the "Login" button
    Then I am redirected to the home screen
    And I see a welcome message "Welcome back!"

  Scenario: Unsuccessful login with invalid credentials
    Given I am on the login screen
    When I enter invalid credentials
    And I tap the "Login" button
    Then I see an error message "Invalid username or password"

  Scenario: Unsuccessful login with empty fields
    Given I am on the login screen
    When I leave the username and password fields empty
    And I tap the "Login" button
    Then I see an error message "Please fill in all fields"