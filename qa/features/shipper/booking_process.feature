@Smoke
Feature: Booking Process

  As a shipper,
  I want to be able to place a booking
  So I would be able to see my bookings online.

  Background:
    Given I am logged in as a shipper successfully
      And I have at least 2 contacts
      And I am on the User Dashboard

  Scenario Outline: Creating a booking
    When I click the find rates button
    Then I expect to see title "Choose shipment"

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
    Then I expect to see title "Final Details"

    When I select my contacts
     And I describe my goods
     And I select "<Insurance>" to Insurance
     And I select "<Clearance>" to Clearance
     And I click "Review Booking Request" button
    Then I expect to see title "Booking Confirmation"

    When I agree to the terms and conditions
     And I click "Finish Booking Request" button
    Then I expect to see title "Thank you for your booking request."

    When I click "Back to dashboard" button
    Then I expect to be redirected to the account page

    Examples:
      | Direction        | Shipment Type             | Origin                                          | Destination                                                               | Shipment                                                               | Insurance | Clearance |
      | Selling (Export) | Ocean FCL & Rail FCL      | William Gibsons väg 13, 433 76 Jonsered, Sweden | Shanghai                                                                  | 1 "20‘ Dry Container" with weight of 2500kg                            | yes       | no        |
      | Selling (Export) | Ocean FCL & Rail FCL      | Gothenburg                                      | 32 Hanzhongmen St, Gulou Qu, Nanjing Shi, Jiangsu Sheng, China, 210029    | 1 "20‘ Dry Container" with weight of 2500kg                            | yes       | no        |
      | Selling (Export) | Ocean FCL & Rail FCL      | William Gibsons väg 13, 433 76 Jonsered, Sweden | 32 Hanzhongmen St, Gulou Qu, Nanjing Shi, Jiangsu Sheng, China, 210029    | 1 "20‘ Dry Container" with weight of 2500kg                            | yes       | no        |
      | Selling (Export) | Ocean FCL & Rail FCL      | Gothenburg                                      | Shanghai                                                                  | 1 "20‘ Dry Container" with weight of 2500kg                            | yes       | no        |
      | Selling (Export) | Ocean FCL & Rail FCL      | Gothenburg                                      | Shanghai                                                                  | 1 "40‘ Dry Container" with weight of 1500kg                            | yes       | no        |
      | Selling (Export) | Air, Ocean LCL & Rail LCL | Gothenburg                                      | Shanghai                                                                  | 1 "Pallet" with length 78cm, width 78cm, height 78cm and weight 800kg  | no        | no        |
      | Buying (Import)  | Ocean FCL & Rail FCL      | Shanghai                                        | Gothenburg                                                                | 1 "20‘ Dry Container" with weight of 2500kg                            | no        | yes       |
      | Buying (Import)  | Ocean FCL & Rail FCL      | Shanghai                                        | Gothenburg                                                                | 1 "40‘ Dry Container" with weight of 1500kg                            | yes       | yes       |
      | Buying (Import)  | Air, Ocean LCL & Rail LCL | Shanghai                                        | Gothenburg                                                                | 1 "Pallet" with length 78cm, width 78cm, height 78cm and weight 800kg  | yes       | no        |
