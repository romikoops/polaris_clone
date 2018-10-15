# frozen_string_literal: true

Given('I am at the landing') do
  visit '/'
end

And('I am logged out') do
  visit '/signout'
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

When('I enter an incorrect email address') do
  fill_in('email', with: 'shipper2@itsmycargo.com')
end

And('I enter an incorrect password') do
  fill_in('password', with: 'IMC1234567891000')
end

Then('I expect to be receive an error message') do
  expect(page).to have_text('Wrong email or password')
end
