@Smoke
Feature: Create Contacts

As a shipper
I want to be able to create contacts
So that I can easily access the information of shipment's senders and receivers

Background:
    Given I am logged in as a shipper successfully
      And I am on the User Dashboard

  Scenario: Create New Contacts
    When I click the "Contacts" tab
    Then I expect to see title "Contacts"

    When I click "New Contact" button
    Then I expect to see the New Contact modal

    When I enter information for my contact
     And I click "Save" button
    Then I expect to see an additional contact