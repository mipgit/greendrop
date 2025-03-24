Feature: Receive notifications and reminders to complete tasks

  Scenario: User receives a notification to water the tree
    Given I have not watered my tree today
    When the notification is triggered
    Then I see a notification with the message "Your tree needs water, don't forget to complete your daily tasks!"

