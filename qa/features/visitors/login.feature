Feature: Login

  As a visitor,
  I want to be to login with the correct credentials

  Scenario: Returning to the homepage after registering 
    Given I am at the homepage
      And I click the link to log in
     Then I expect to see the log in modal

    When I enter the correct email address
     And I enter the correct password
     And I click the sign in button
    Then I expect to be redirected to the account page

