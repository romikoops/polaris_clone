@Smoke
Feature: Request Dedicated Pricing

  As a shipper,
  I want to be able to view my available routes and rates
  So that I know how much shipping my cargo would cost.
  I also would like to request a dedicated rate for a route

  Background:
    Given I have accepted cookies

  Scenario: Requesting New Rate
    Given I am logged in as a shipper successfully
      And I select "Pricings"
     Then I expect to see title "Pricings"

    Given I am on the Pricings Page
      And I request the first public rate
     Then I expect to see the rate has been requested
