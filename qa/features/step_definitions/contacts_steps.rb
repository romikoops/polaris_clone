# frozen_string_literal: true

When('I enter information for my contact') do
  rand_string = SecureRandom.hex(10)
  @email = "#{rand_string}@itsmycargo.test"
  fill_in('firstName', with: FFaker::Name.first_name)
  fill_in('lastName', with: FFaker::Name.last_name)
  fill_in('companyName', with: FFaker::Company.name)
  fill_in('phone', with: FFaker::PhoneNumberDE.phone_number)
  fill_in('email', with: @email)
  fill_in('street', with: FFaker::AddressDE.street_name)
  fill_in('number', with: rand(2**10))
  fill_in('zipCode', with: FFaker::AddressDE.zip_code)
  fill_in('city', with: FFaker::AddressDE.city)
  fill_in('country', with: 'Germany')
end

Then('I expect to see an additional contact') do
  expect(page).to have_text(@email)
end

Then 'I expect to see the New Contact modal' do
  expect(page).to have_css('.ccb_contact_form')
end

And('I have at least {int} contacts') do |contact|
  step 'I click the "Contacts" tab'
  step 'I expect to see title "Contacts"'
  contact.times do
    step 'I click "New Contact" button'
    step 'I expect to see the New Contact modal'
    step 'I enter information for my contact'
    step 'I click "Save" button'
  end
end
