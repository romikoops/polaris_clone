# frozen_string_literal: true

module MultiTenantTools
  include ExcelTools

  API_URL = 'https://api.itsmycargo.com'
  DEV_API_URL = 'https://gamma.itsmycargo.com'

  def asset_bucket
    Aws::S3::Client.new(
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key
    )
  end

  def create_internal_users(tenant)
    unless tenant.users.exists?(email: 'shopadmin@itsmycargo.com')
      user = tenant.users.create!(
        email: 'shopadmin@itsmycargo.com',
        role: Role.find_by(name: 'admin'),
        password: 'IMC123456789',
        guest: false,
        currency: 'EUR',
        optin_status_id: 1,
        internal: true
      )
      create_user_profile(user: user,
                          first_name: 'IMC',
                          last_name: 'Admin',
                          company_name: 'ItsMyCargo GmbH')
    end
    if quotation_tool?(tenant)
      unless tenant.users.exists?(email: 'manager@itsmycargo.com')
        user = tenant.users.create!(
          email: 'manager@itsmycargo.com',
          role: Role.find_by(name: 'manager'),
          guest: false,
          password: 'IMC123456789',
          currency: 'EUR',
          optin_status_id: 1,
          internal: true
        )
        create_user_profile(user: user,
                            first_name: 'IMC',
                            last_name: 'Admin',
                            company_name: 'ItsMyCargo GmbH')
      end
      unless tenant.users.exists?(email: 'agent@itsmycargo.com')
        user = tenant.users.create!(
          email: 'agent@itsmycargo.com',
          role: Role.find_by(name: 'agent'),
          guest: false,
          password: 'IMC123456789',
          currency: 'EUR',
          optin_status_id: 1,
          internal: true
        )
        create_user_profile(user: user,
                            first_name: 'IMC',
                            last_name: 'Admin',
                            company_name: 'ItsMyCargo GmbH')
      end
    else
      unless tenant.users.exists?(email: 'shipper@itsmycargo.com')
        shipper = tenant.users.create!(
          email: 'shipper@itsmycargo.com',
          role: Role.find_by(name: 'shipper'),
          guest: false,
          password: 'IMC123456789',
          currency: 'EUR',
          optin_status_id: 1,
          internal: true
        )
        create_user_profile(user: shipper,
                            first_name: 'IMC',
                            last_name: 'Admin',
                            company_name: 'ItsMyCargo GmbH')
      end
    end
  end

  def create_new_tenant_site(subdomains)
    subdomains.each do |subdomain|
      json_data = JSON.parse(
        asset_bucket.get_object(bucket: 'assets.itsmycargo.com', key: "data/#{subdomain}/#{subdomain}.json").body.read
      ).deep_symbolize_keys
      new_site(json_data, false)
    end
  end

  def seed_demo_site(subdomain, tld) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    tenant = Tenant.find_by_subdomain(subdomain)
    tenant.users.destroy_all
    admin = tenant.users.new(
      role: Role.find_by_name('admin'),
      email: "admin@#{subdomain}.#{tld}",
      password: 'demo123456789',
      password_confirmation: 'demo123456789',
      confirmed_at: DateTime.new(2017, 1, 20)
    )

    admin.save!
    create_user_profile(user: admin,
                        first_name: 'Admin',
                        last_name: 'Admin',
                        company_name: tenant.name,
                        phone: '123456789')

    shipper = tenant.users.new(
      role: Role.find_by_name('shipper'),
      email: "demo@#{::Tenants::Tenant.find_by(legacy_id: tenant.id).slug}.#{tld}",
      password: 'demo123456789',
      password_confirmation: 'demo123456789',
      confirmed_at: DateTime.new(2017, 1, 20)
    )
    # shipper.skip_confirmation!
    shipper.save!
    create_user_profile(user: shipper,
                        first_name: 'John',
                        last_name: 'Smith',
                        company_name: 'Example Shipper Company',
                        phone: '123456789')
    # Create dummy addresses for shipper
    dummy_addresses = [
      {
        street: 'Kehrwieder',
        street_number: '2',
        zip_code: '20457',
        city: 'Hamburg',
        country: Country.find_by_code('DE')
      },
      {
        street: 'Carer del Cid',
        street_number: '13',
        zip_code: '08001',
        city: 'Barcelona',
        country: Country.find_by_code('ES')
      },
      {
        street: 'College Rd',
        street_number: '1',
        zip_code: 'PO1 3LX',
        city: 'Portsmouth',
        country: Country.find_by_code('GB')
      },
      {
        street: 'Tuna St',
        street_number: '64',
        zip_code: '90731',
        city: 'San Pedro',
        country: Country.find_by_code('US')
      }
    ]

    dummy_addresses.each do |l|
      loc = Address.create_and_geocode(l)
      shipper.addresses << loc
    end

    # Create dummy contacts for shipper address book
    dummy_contacts = [
      {
        company_name: 'Example Shipper Company',
        first_name: 'John',
        last_name: 'Smith',
        phone: '123456789',
        email: "demo@#{::Tenants::Tenant.find_by(legacy_id: tenant.id).slug}.com"
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
      loc = Address.find_or_create_by(dummy_addresses[i])
      contact[:address_id] = loc.id
      shipper.contacts.create(contact)
    end

  end

  def quick_seed(subdomain)
    puts 'Seed prcings'
    PricingSeeder.perform(subdomain: subdomain)
  end

  def quotation_tool?(tenant)
    scope = ::Tenants::ScopeService.new(
      tenant: ::Tenants::Tenant.find_by(legacy_id: tenant&.id)
    ).fetch

    scope['open_quotation_tool'] || scope['closed_quotation_tool']
  end

  def create_user_profile(user:, first_name:, last_name:, company_name:, phone: nil)
    tenants_user = Tenants::User.find_by(legacy_id: user.id)
    Profiles::ProfileService.create_or_update_profile(user: tenants_user,
                                                      first_name: first_name,
                                                      last_name: last_name,
                                                      company_name: company_name,
                                                      phone: phone)
  end
end
