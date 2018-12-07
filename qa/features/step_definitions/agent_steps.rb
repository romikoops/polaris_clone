# frozen_string_literal: true

Given('I am logged in as an agent') do
  step 'I am at the landing'
  step 'I click the link to log in'
  step 'I enter the correct agent email address'
  step 'I enter the correct agent password'
  step 'I click the sign in button'
end

When('I enter the correct agent email address') do
  fill_in('email', with: 'agent@itsmycargo.com')
end

And('I enter the correct agent password') do
  fill_in('password', with: 'IMC123456789')
end

And('I select the first quote') do
  all('.ccb_select_quote').first.click
end

And('I download the PDF') do
  quote_bar = find('.quote_options')
  request_doc_box = quote_bar.find('div', class: 'document_downloader')
  request_doc_box.find('div', class: 'request').find('button').click
  expect(page).to have_css('#floatingCirclesG')
  expect(page).to have_no_css('#floatingCirclesG', wait: 90)
end

And('I have not selected and offer, the button is disabled') do
  quote_bar = find('.quote_options')
  request_doc_box = quote_bar.find('div', class: 'document_downloader')
  expect(request_doc_box.find('div', class: 'request').find('button')).to have_no_css('false')
end
