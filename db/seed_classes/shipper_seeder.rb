# frozen_string_literal: true

class ShipperSeeder
  DUMMY_LOCATIONS = [
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
  ].freeze

  DUMMY_CONTACTS = [
    {
      company_name: 'Example Shipper Company',
      first_name: 'John',
      last_name: 'Smith',
      phone: '123456789',
      email: 'demo@**subdomain**.com'
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
  ].freeze

  def self.perform(filter = {})
    Tenant.where(filter).each do |tenant|
      shipper = find_shipper_for_tenant(tenant)
      shipper ||= new_shipper(tenant)
      shipper.save!

      add_dummy_locations_to_shipper(shipper)
      add_dummy_contacts_to_shipper(shipper)
    end
  end

  private

  def self.tld(tenant)
    tenant.web && tenant.web['tld'] ? tenant.web['tld'] : 'com'
  end

  def self.find_shipper_for_tenant(tenant)
    tenant.users.find_by(uid: "#{tenant.id}***demo@#{tenant.subdomain}.#{tld(tenant)}")
  end

  def self.new_shipper(tenant)
    tenant.users.new(
      role: Role.find_by_name('shipper'),
      company_name: 'Example Shipper Company',
      first_name: 'John',
      last_name: 'Smith',
      phone: '123456789',
      email: "demo@#{tenant.subdomain}.#{tld(tenant)}",
      password: 'demo123456789',
      password_confirmation: 'demo123456789',
      confirmed_at: DateTime.new(2017, 1, 20)
    )
  end

  def self.add_dummy_locations_to_shipper(shipper)
    DUMMY_LOCATIONS.each do |location_hash|
      location = Location.create_and_geocode(location_hash)
      next if shipper.locations.include?(location)

      shipper.locations << location
    end
  end

  def self.add_dummy_contacts_to_shipper(shipper)
    DUMMY_CONTACTS.each_with_index do |contact_hash, i|
      if should_insert_domain?(contact_hash[:email])
        contact_hash[:email] = contact_hash[:email].gsub('**subdomain**', shipper.tenant.subdomain)
      end
      contact_hash[:location_id] = Location.find_or_create_by(DUMMY_LOCATIONS[i]).id
      contact = Contact.create(contact_hash)
      next if shipper.contacts.include?(contact)

      shipper.contacts << contact
    end
  end

  def self.should_insert_domain?(email)
    match_data = email.match(/\*\*(?<wilcard_text>.*)\*\*/)
    match_data && match_data[:wilcard_text] == 'subdomain'
  end
end
