# frozen_string_literal: true

Given('I am on the Pricings Page') do
  visit '/account/pricings'
end

When('I request the first public rate') do
  itinerary_rows = all('.rt-tr-group')
  itinerary_rows.each do |it_row|
    next if @rate_row

    it_row.find('.rt-expander').click
    pricings_rows = it_row.find('.ReactTable').all('.rt-tr-group')

    @rate_row = pricings_rows.find do |p_row|
      next unless p_row.has_selector?('button', wait: 1)

      button = p_row.find('button')

      button.click

      p_row
    end
  end
end

Then('I expect to see the rate has been requested') do
  pending
  expect(@rate_row).to have_content('Requested')
end
