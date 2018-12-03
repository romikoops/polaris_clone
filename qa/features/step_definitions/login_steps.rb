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
When('I accept the cookies if the bar is there') do
  # button = find('button', class: 'S2dJZ4GCoTCWo4F7HGPQK')
  button = find('button', class: '.ccb_accept_cookies')
  button.click unless button.nil?
  
end

Then('I expect to see the log in modal') do
  expect(page).to have_button('Sign In')
end

When('I enter the correct credentials') do
  fill_in('email', with: 'shipper@itsmycargo.com')
  fill_in('password', with: 'IMC123456789')
end

And('I click the sign in button') do
  click_button('Sign In')
end

Then('I expect to be redirected to the account page') do
  expect(page).to have_css('.ccb_dashboard', wait: 20)
end

When('I enter an incorrect credentials') do
  fill_in('email', with: 'shipper2@itsmycargo.com')
  fill_in('password', with: 'IMC1234567891000')
end

Then('I expect to be receive an error message') do
  expect(page).to have_text('Wrong email or password')
end
