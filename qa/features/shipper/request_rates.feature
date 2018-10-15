Feature: Find Rates

  As a end user,
  I want to be able to view my available routes and rates
  So that I know how much shipping my cargo would cost.
  I also would like to request a dedicated rate for a route

  Scenario: Requesting New Rate
    Given I am logged in successfully
      And I select "Pricings"
     Then I expect to see title "Pricings"

    Given I am on the Pricings Page
      And I request the first public rate
     Then I expect to see the rate has been requested
