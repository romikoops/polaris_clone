# frozen_string_literal: true

Given ('I am logged in successfully') do
  step 'I am at the landing'
  step 'I am logged out'
  step 'I click the link to log in'
  step 'I expect to see the log in modal'

  step 'I enter the correct email address'
  step 'I enter the correct password'
  step 'I click the sign in button'
  step 'I expect to be redirected to the account page'
end

When('I set trucking from {string} to {string}') do |address, type|
  elem = find('div', class: "auto_#{type.downcase}", wait: 10)
  address.split(',').each do |ac|
    elem.find('input').send_keys(ac)
    desired_result = elem.find('.results').has_content?(address)
    elem.find('.results').find('.address').find('div', text: address).click if desired_result
  end
end

When('I have LCL shipment of {int} units {int} x {int} x {int} with weight of {int}kg') do |count, dim_x, dim_y, dim_z, weight|
  # Select container size
  cargo_item_1 = find("div[name='0-cargoItem']")
  elem = cargo_item_1.find('.colli_type', visible: false)
  control = elem.find(class: 'Select-control')
  control.find(class: 'Select-arrow-zone').click

  find('.Select-option', text: 'Pallet').click
  # Quantity
  fill_in '0-quantity', with: count

  # Dimensions
  fill_in '0-dimension_x', with: dim_x
  fill_in '0-dimension_y', with: dim_y
  fill_in '0-dimension_z', with: dim_z

  # Weight
  fill_in '0-payload_in_kg', with: weight
end
