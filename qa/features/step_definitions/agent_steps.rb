Given ('I am logged in as an agent') do 
  step "I am at the landing"
  step "I click the link to log in"
  step "I enter the correct agent email address"
  step "I enter the correct agent password"
  step "I click the sign in button"
end


When('I enter the correct agent email address') do
  fill_in('email', with: 'agent@itsmycargo.com')
end

And('I enter the correct agent password') do
  fill_in('password', with: 'IMC123456789')
end
