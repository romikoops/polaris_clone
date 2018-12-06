@Feature-QuoteTool
Feature: Find Quotes

  As an agent,
  I want to be able to find rates
  So that I know how much to charge my clients for their shipment.

  Background:
    Given I am at the homepage
      And I am logged out
      And I have accepted cookies

  Scenario: Requesting FCL Quote
    Given I am logged in as an agent
     When I click the find rates button
     Then I expect to see title "Choose shipment"

     When I select "I am Selling (Export)"
      And I click "Next Step" button
     Then I expect to see title "Shipment Details"

     When I select "Hamburg" as "Origin"
      And I select "Kuantan" as "Destination"
      And I have shipment of 2 "40‘ Dry Container" with weight of 14000kg
      And I confirm cargo does not contain dangerous good
      And I click "Get Quotes" button

    Then I expect to see title "View Quotes"
     And I expect to see offers

    When I have not selected and offer, the button is disabled
     And I select the first quote
     And I download the PDF
