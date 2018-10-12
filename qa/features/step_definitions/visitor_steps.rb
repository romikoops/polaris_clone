# frozen_string_literal: true

Given('I am at the homepage') do
  visit '/'
end

When('I click {string} button') do |string|
  click_button(string)
end

Then('I expect to see title {string}') do |string|
  expect(page).to have_content(string)
end

When('I select {string}') do |string|
  find('p', text: string).click
end

When('I select {string} as {string}') do |place, type|
  elem = find('div', class: 'Select-placeholder', text: type, wait: 10)
  elem.sibling('.Select-input').find('input').send_keys(place)
  find('.Select-option', text: place).click
end

When('I select {string} as Available Date') do |string|
  date = Chronic.parse(string)
  find(class: 'DayPickerInput').find('input').send_keys(date.strftime('%d/%m/%Y'))
  all('.DayPicker-Day', text: date.day).first.click
end

When('I have shipment of {int} {string} with weight of {int}kg') do |count, size, weight|
  # Select container size
  elem = find("input[name='0-container_size']", visible: false)
  control = elem.sibling(class: 'Select-control')
  control.find(class: 'Select-arrow-zone').click

  find('.Select-option', text: size).click

  # Weight
  fill_in '0-payload_in_kg', with: weight

  # Quantity
  control = find("input[name='0-quantity']", visible: false).sibling(class: 'Select-control')
  control.find(class: 'Select-arrow-zone').click
  control.sibling(class: 'Select-menu-outer').find('.Select-option', text: /\A#{count}\z/).click
end

When('I have shipment of {int} {string} with length {int}cm, width {int}cm, height {int}cm and weight {int}kg') do |count, colli, length, width, height, weight|
  # Select colli type
  elem = find("input[name='0-colliType']", visible: false)
  control = elem.first(:xpath, './/..//..//..')
  control.find(class: 'Select-arrow-zone').click

  find('.Select-option', text: colli).click

  # Length
  fill_in '0-dimension_x', with: length

  # Width
  fill_in '0-dimension_y', with: width

  # Height
  fill_in '0-dimension_z', with: height

  # Weight
  fill_in '0-payload_in_kg', with: weight

  # Quantity
  fill_in '0-quantity', with: count
end

When('I confirm cargo does not contain dangerous good') do
  find("input[name='no_dangerous_goods_confirmation']", visible: false).sibling('span').click
end

Then('I expect to see offers') do
  offers = all('.offer_result')
  expect(offers.count).to be >= 1
end

When('I select first offer') do
  buttons = all(:xpath, "//button[.//*[contains(text(),'Select')]]")
  buttons.first.click
end

Then('I expect to be requested for signing in.') do
  expect(page).to have_button('Sign In')
end
