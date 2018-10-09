# frozen_string_literal: true
Given('I am at the landing') do
  visit '/'
end

When('I click the link to log in') do
  find('a', text: 'Log In / Register').click
end

Then('I expect to see the log in modal') do
  expect(page).to have_button('Sign In')
end

When('I enter the correct email address') do
  fill_in('email', with: 'shipper@itsmycargo.com')
end

And('I enter the correct password') do
  fill_in('password', with: 'IMC123456789')
end

And('I click the sign in button') do
  click_button('Sign In')
end

Then('I expect to be redirected to the account page') do
  expect(page).to have_text('Welcome back')
end