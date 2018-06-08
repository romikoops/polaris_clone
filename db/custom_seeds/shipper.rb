# frozen_string_literal: true

Tenant.all.each do |tenant|
  # Create shipper
  tld = tenant.web && tenant.web['tld'] ? tenant.web['tld'] : 'com'
  user_check = tenant.users.find_by(email: "demo@#{tenant.subdomain}.#{tld}")

  if !user_check
    shipper = tenant.users.new(
      role: Role.find_by_name('shipper'),
      company_name: 'Example Shipper Company',
      first_name: 'John',
      last_name: 'Smith',
      phone: '123456789',
      email: "demo@#{tenant.subdomain}.#{tld}",
      password: 'demo123456789',
      password_confirmation: 'demo123456789',
      confirmed_at: DateTime.new(2017, 1, 20)
    )
    # shipper.skip_confirmation!
    shipper.save!
  else
    next
  end

  # Create dummy locations for shipper
  dummy_locations = [
    {
      street: 'Kehrwieder',
      street_number: '2',
      zip_code: '20457',
      city: 'Hamburg',
      country: Country.find_by(code: 'DE')
    },
    {
      street: 'Carer del Cid',
      street_number: '13',
      zip_code: '08001',
      city: 'Barcelona',
      country: Country.find_by(code: 'ES')
    },
    {
      street: 'College Rd',
      street_number: '1',
      zip_code: 'PO1 3LX',
      city: 'Portsmouth',
      country: Country.find_by(code: 'GB')
    },
    {
      street: 'Tuna St',
      street_number: '64',
      zip_code: '90731',
      city: 'San Pedro',
      country: Country.find_by(code: 'US')
    }
  ]

  dummy_locations.each do |l|
    loc = Location.create_and_geocode(l)
    shipper.locations << loc
  end

  # Create dummy contacts for shipper address book
  dummy_contacts = [
    {
      company_name: 'Example Shipper Company',
      first_name: 'John',
      last_name: 'Smith',
      phone: '123456789',
      email: "demo@#{tenant.subdomain}.com"
    },
    {
      company_name: 'Another Example Shipper Company',
      first_name: 'Jane',
      last_name: 'Doe',
      phone: '123456789',
      email: 'jane@doe.com'
    },
    {
      company_name: 'Yet Another Example Shipper Company',
      first_name: 'Javier',
      last_name: 'Garcia',
      phone: '0034123456789',
      email: 'javi@shipping.com'
    },
    {
      company_name: 'Forwarder Company',
      first_name: 'Gertrude',
      last_name: 'Hummels',
      phone: '0049123456789',
      email: 'gerti@fwd.com'
    },
    {
      company_name: 'Another Forwarder Company',
      first_name: 'Jerry',
      last_name: 'Lin',
      phone: '001123456789',
      email: 'jerry@fwder2.com'
    }
  ]

  dummy_contacts.each_with_index do |contact, i|
    loc = Location.find_or_create_by(dummy_locations[i])
    contact[:location_id] = loc.id
    shipper.contacts.create(contact)
  end
end
