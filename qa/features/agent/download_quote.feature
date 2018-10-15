Feature: Find Quotes

  As an agent,
  I want to be able to find rates
  So that I know how much to charge my clients for their shipment.

  Background:
    Given I am at the homepage
      And I am logged out

  @wip
  Scenario: Requesting LCL Quote
    Given I am logged in as an agent
      And I click "Find Rates" button
     Then I expect to see title "Choose shipment"

    When I select "I am Selling (Export)"
     And I select "Ocean LCL"
     And I click "Next Step" button
    Then I expect to see title "Shipment Details"

     And I select "Dalian" as "Destination"
    When I set trucking from "Brooktorkai 7, Hamburg" to "Origin"

     And I select "1 week from now" as Available Date
     And I have LCL shipment of 1 units 120 x 80 x 120 with weight of 1500kg
     And I confirm cargo does not contain dangerous good
     And I click "Get Offers" button

    Then I expect to see title "View Quotes"
     And I expect to see offers
    When I have not selected and offer, the button is disabled
     And I select the first quote
     And I download the PDF
