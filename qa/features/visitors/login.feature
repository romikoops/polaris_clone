Feature: Login

  As a visitor,
  I want to be to login with the correct credentials

  Background:
    Given I am at the homepage
      And I am logged out
      And I click the link to log in
     Then I expect to see the log in modal

  Scenario: Returning to the account page after login
    When I enter the correct credentials
     And I click the sign in button
    Then I expect to be redirected to the account page

  Scenario: When I enter the incorrect credentials, I cannot log in
    When I enter an incorrect credentials
     And I click the sign in button
    Then I expect to be receive an error message
