# frozen_string_literal: true

Given('I am on the Pricings Page') do
  visit '/account/pricings'
end

When('I request the first public rate') do
  itinerary_rows = all('.rt-tr-group')
  itinerary_rows.each do |it_row|
    next if @rate_row
    it_row.find('.rt-expander').click
    pricing_table = it_row.find('.ReactTable')
    pricings_rows = pricing_table.all('.rt-tr-group')
    pricings_rows.each do |p_row|
      next if @rate_row

      button = p_row.find('button')
      next if !button
      
      @rate_row = p_row
      button.click
    end
  end
end

Then('I expect to see the rate has been requested') do
  pending
  expect(@rate_row).to have_content('Requested')
end
