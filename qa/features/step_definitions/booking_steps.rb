# frozen_string_literal: true

When('I select my contacts') do
  step 'I select choose a sender'
  step 'I have more than 1 contacts'
  step 'I select a sender'
  step 'I select choose a receiver'
  step 'I select a receiver'
end

And('I describe my goods') do
  step 'I have a goods value of'
  step 'I enter a description for my goods'
end

When('I click the find rates button') do
  find('.ccb_find_rates', wait: 45).click
end

When('I select choose a sender') do
  find('.ccb_shipper').click
end

And('I select a sender') do
  elem = all('.ccb_contact').first
  elem.click
end

And('I select choose a receiver') do
  find('.ccb_consignee').click
end

And('I select a receiver') do
  elem = all('.ccb_contact').last
  elem.click
end

# test needs to be added for notifyee
# needs to account for when there are less than three contacts

And('I have a goods value of') do
  fill_in 'totalGoodsValue', with: '100'
end

And('I enter a description for my goods') do
  fill_in 'cargoNotes', with: 'These are some goods.'
end

And('I select {string} to Insurance') do |insurance|
  find(".ccb_#{insurance}_insurance").click
end

And('I select {string} to Clearance') do |clearance|
  clearance_class_name = ".ccb_#{clearance}_clearance"
  find(clearance_class_name).click
end

When('I agree to the terms and conditions') do
  expect(all('.ccb_accept_terms .fa-check').count).to eq(0)
  find('.ccb_accept_terms').click
  expect(all('.ccb_accept_terms .fa-check').count).to eq(1)
end

And('I have more than {int} contacts') do |num_contacts|
  expect(all('.ccb_contact').count).to be > num_contacts
end
