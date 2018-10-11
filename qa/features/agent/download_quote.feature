Feature: Find Rates

  As a visitor,
  I want to be able to find rates
  So that I know how much shipping my cargo would cost.

  Scenario: Requesting LCL Quote
    Given I am at the homepage
      And I click "Find Rates" button
     Then I expect to see title "Choose shipment"

    When I select "I am Selling (Export)"
     And I select "Ocean FCL & Rail FCL"
     And I click "Next Step" button
    Then I expect to see title "Shipment Details"

    When I select "Shanghai" as "Origin"
     And I select "Gothenburg" as "Destination"
     And I select "1 week from now" as Available Date
     And I have shipment of 1 "40‘ Dry Container" with weight of 1500kg
     And I confirm cargo does not contain dangerous good
     And I click "Get Offers" button

    Then I expect to see title "Choose Offer"
     And I expect to see offers

    When I select first offer
    Then I expect to be requested for signing in.
