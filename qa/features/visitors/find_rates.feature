@Smoke
Feature: Find Rates

  As a visitor,
  I want to be able to find rates
  So that I know how much shipping my cargo would cost.

  Background:
    Given I am logged out
      And I am at the homepage
      And I click "Find Rates" button
     Then I expect to see title "Choose shipment"

  Scenario Outline: Requesting Shipment
    When I select "I am <Direction>"
     And I select "<Shipment Type>"
     And I click "Next Step" button
    Then I expect to see title "Shipment Details"

    When I select "<Origin>" as "Origin"
     And I select "<Destination>" as "Destination"
     And I select "1 week from now" as Available Date
     And I have shipment of <Shipment>
     And I confirm cargo does not contain dangerous good
     And I click "Get Offers" button

    Then I expect to see title "Choose Offer"
     And I expect to see offers

    When I select first offer
    Then I expect to be requested for signing in.

    Examples:
      | Direction        | Shipment Type             | Origin     | Destination | Shipment                                                              |
      | Selling (Export) | Ocean FCL & Rail FCL      | Gothenburg | Shanghai    | 1 "20‘ Dry Container" with weight of 2500kg                           |
      | Selling (Export) | Ocean FCL & Rail FCL      | Gothenburg | Shanghai    | 1 "40‘ Dry Container" with weight of 1500kg                           |
      | Selling (Export) | Air, Ocean LCL & Rail LCL | Gothenburg | Shanghai    | 1 "Pallet" with length 78cm, width 78cm, height 78cm and weight 800kg |
      | Buying (Import)  | Ocean FCL & Rail FCL      | Shanghai   | Gothenburg  | 1 "20‘ Dry Container" with weight of 2500kg                           |
      | Buying (Import)  | Ocean FCL & Rail FCL      | Shanghai   | Gothenburg  | 1 "40‘ Dry Container" with weight of 1500kg                           |
      | Buying (Import)  | Air, Ocean LCL & Rail LCL | Shanghai   | Gothenburg  | 1 "Pallet" with length 78cm, width 78cm, height 78cm and weight 800kg |
