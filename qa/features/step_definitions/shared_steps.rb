Given ('I am logged in successfully') do 
  step "I am at the landing"
  step "I am logged out"
  step "I click the link to log in"
  step "I expect to see the log in modal"

  step "I enter the correct email address"
  step "I enter the correct password"
  step "I click the sign in button"
  step "I expect to be redirected to the account page"
end