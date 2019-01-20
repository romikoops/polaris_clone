@Smoke
Feature: FCL Export Booking

  As a shipper,
  I want to be able to place a booking for FCL
  So I would be able to see my bookings online.

  Background:
    Given I am logged in as a shipper successfully
      And I have at least 2 contacts
      And I am on the User Dashboard

  Scenario Outline: Creating a booking
    When I click the find rates button
    Then I expect to see title "Choose shipment"

    When I select "I am Selling (Export)"
     And I select "Ocean FCL & Rail FCL"
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
     And I click "Review Booking Request" button
    Then I expect to see title "Booking Confirmation"

    When I agree to the terms and conditions
     And I click "Finish Booking Request" button
    Then I expect to see title "Thank you for your booking request."

    When I click "Back to dashboard" button
    Then I expect to be redirected to the account page

    Examples:
      | Origin                                          | Destination                    | Shipment                                     |
      | Gothenburg                                      | Shanghai                       | 1 "40‘ Dry Container" with weight of 19000kg |
      | Gothenburg                                      | Henan Middle Road 88, Shanghai | 1 "20‘ Dry Container" with weight of 9000kg  |
      | William Gibsons väg 13, 433 76 Jonsered, Sweden | Shanghai                       | 1 "20‘ Dry Container" with weight of 9000kg  |
      | William Gibsons väg 13, 433 76 Jonsered, Sweden | Henan Middle Road 88, Shanghai | 1 "20‘ Dry Container" with weight of 9000kg  |
