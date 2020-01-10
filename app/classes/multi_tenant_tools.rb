# frozen_string_literal: true

module MultiTenantTools
  include ExcelTools

  API_URL = 'https://api2.itsmycargo.com'
  DEV_API_URL = 'https://gamma.itsmycargo.com'

  def s3_signer
    Aws::S3::Presigner.new(
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key
    )
  end

  def deploy_bucket
    Aws::S3::Client.new(
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region: 'us-east-1'
    )
  end

  def asset_bucket
    Aws::S3::Client.new(
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key
    )
  end

  def update_indexes
    Tenant.find_each do |tenant|
      title = tenant.name + ' | ItsMyCargo'
      favicon = 'https://assets.itsmycargo.com/assets/favicon.ico'
      # indexHtml = Nokogiri::HTML(open("https://demo.itsmycargo.com/index.html"))
      indexHtml = Nokogiri::HTML(open(Rails.root.to_s + '/client/dist/index.html'))

      titles = indexHtml.xpath('//title')
      titles[0].content = title
      links = indexHtml.xpath('//link')

      links.each do |lnk|
        if lnk.attributes && lnk.attributes['href'] && lnk.attributes['href'].value == 'https://assets.itsmycargo.com/assets/favicon.ico'
          lnk.content = favicon
        end
      end

      objKey = tenant['subdomain'] + '.html'
      newHtml = indexHtml.to_html
      # Replace API Host and tenantName
      newHtml.gsub!('__API_URL__', API_URL)
      newHtml.gsub!('__TENANT_SUBDOMAIN__', ::Tenants::Tenant.find_by(legacy_id: tenant.id).slug)

      deploy_bucket.put_object(bucket: 'multi.itsmycargo.com', key: objKey, body: StringIO.new(newHtml), content_type: 'text/html', acl: 'public-read')
      invalidate(tenant.web['cloudfront'], ::Tenants::Tenant.find_by(legacy_id: tenant.id).slug) if tenant.web && tenant.web['cloudfront']
    end
  end

  def update_tenant(subdomain)
    # Tenant.all.each do |tenant|
    Tenant.where(subdomain: subdomain).each do |tenant|
      title = tenant.name + ' | ItsMyCargo'
      favicon = 'https://assets.itsmycargo.com/assets/favicon.ico'
      # indexHtml = Nokogiri::HTML(open("https://demo.itsmycargo.com/index.html"))
      indexHtml = Nokogiri::HTML(open(Rails.root.to_s + '/client/dist/index.html'))
      titles = indexHtml.xpath('//title')
      titles[0].content = title
      links = indexHtml.xpath('//link')

      links.each do |lnk|
        if lnk.attributes && lnk.attributes['href'] && lnk.attributes['href'].value == 'https://assets.itsmycargo.com/assets/favicon.ico'
          lnk.content = favicon
        end
      end

      objKey = tenant['subdomain'] + '.html'
      newHtml = indexHtml.to_html
      # Replace API Host and tenantName
      newHtml.gsub!('__API_URL__', DEV_API_URL)
      newHtml.gsub!('__TENANT_SUBDOMAIN__', ::Tenants::Tenant.find_by(legacy_id: tenant.id).slug)

      deploy_bucket.put_object(bucket: 'multi.itsmycargo.com', key: objKey, body: StringIO.new(newHtml), content_type: 'text/html', acl: 'public-read')
      invalidate(tenant.web['cloudfront'], ::Tenants::Tenant.find_by(legacy_id: tenant.id).slug) if tenant.web && tenant.web['cloudfront']
    end
  end

  def create_sandboxes
    sandbox_tenants = []
    Tenant.all.map do |t|
      sandbox_tenants << t if ::Tenants::Tenant.find_by(legacy_id: t.id).slug.include? 'sandbox'
    end

    sandbox_tenants.each do |st|
      new_site_from_tenant(st)
    end
  end

  def create_internal_users(tenant)
    unless tenant.users.exists?(email: 'shopadmin@itsmycargo.com')
      tenant.users.create!(
        email: 'shopadmin@itsmycargo.com',
        role: Role.find_by(name: 'admin'),
        company_name: 'ItsMyCargo GmbH',
        first_name: 'IMC',
        last_name: 'Admin',
        password: 'IMC123456789',
        guest: false,
        currency: 'EUR',
        optin_status_id: 1,
        internal: true
      )
    end
    if quotation_tool?(tenant)
      unless tenant.users.exists?(email: 'manager@itsmycargo.com')
        tenant.users.create!(
          email: 'manager@itsmycargo.com',
          role: Role.find_by(name: 'manager'),
          company_name: 'ItsMyCargo GmbH',
          first_name: 'IMC',
          last_name: 'Admin',
          guest: false,
          password: 'IMC123456789',
          currency: 'EUR',
          optin_status_id: 1,
          internal: true
        )
      end
      unless tenant.users.exists?(email: 'agent@itsmycargo.com')
        tenant.users.create!(
          email: 'agent@itsmycargo.com',
          role: Role.find_by(name: 'agent'),
          company_name: 'ItsMyCargo GmbH',
          first_name: 'IMC',
          last_name: 'Admin',
          guest: false,
          password: 'IMC123456789',
          currency: 'EUR',
          optin_status_id: 1,
          internal: true
        )
      end
    else
      unless tenant.users.exists?(email: 'shipper@itsmycargo.com')
        tenant.users.create!(
          email: 'shipper@itsmycargo.com',
          role: Role.find_by(name: 'shipper'),
          company_name: 'ItsMyCargo GmbH',
          first_name: 'IMC',
          last_name: 'Admin',
          guest: false,
          password: 'IMC123456789',
          currency: 'EUR',
          optin_status_id: 1,
          internal: true
        )
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

  def new_site(tenant, _is_demo)
    tenant.delete(:other_data)
    new_tenant = Tenant.create!(tenant)
    tenants_tenant = Tenants::Tenant.find_by(legacy_id: new_tenant.id)
    Tenants::Scope.create(target: tenants_tenant, content: {})
    title = tenant[:name] + ' | ItsMyCargo'
    meta = tenant[:meta]
    favicon = tenant[:favicon] || 'https://assets.itsmycargo.com/assets/favicon.ico'
    indexHtml = Nokogiri::HTML(open(Rails.root.to_s + '/client/dist/index.html'))
    titles = indexHtml.xpath('//title')
    titles[0].content = title
    metas = indexHtml.xpath('//meta')
    links = indexHtml.xpath('//link')

    links.each do |lnk|
      if lnk.attributes && lnk.attributes['href'] && lnk.attributes['href'].value == 'https://assets.itsmycargo.com/assets/favicon.ico'
        lnk.content = favicon
      end
    end

    objKey = tenant[:subdomain] + '.html'
    newHtml = indexHtml.to_html
    deploy_bucket.put_object(bucket: 'multi.itsmycargo.com', key: objKey, body: StringIO.new(newHtml), content_type: 'text/html', acl: 'public-read')

    create_distribution(tenant[:subdomain])
  end

  def new_site_from_tenant(subdomain)
    tenant = ::Tenants::Tenant.find_by(slug: subdomain).legacy
    title = tenant.name + ' | ItsMyCargo'

    favicon = 'https://assets.itsmycargo.com/assets/favicon.ico'
    indexHtml = Nokogiri::HTML(open(Rails.root.to_s + '/client/dist/index.html'))
    titles = indexHtml.xpath('//title')
    titles[0].content = title
    metas = indexHtml.xpath('//meta')
    links = indexHtml.xpath('//link')

    links.each do |lnk|
      if lnk.attributes && lnk.attributes['href'] && lnk.attributes['href'].value == 'https://assets.itsmycargo.com/assets/favicon.ico'
        lnk.content = favicon
      end
    end

    s3 = Aws::S3::Client.new(
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region: 'us-east-1'
    )
    objKey = ::Tenants::Tenant.find_by(legacy_id: tenant.id).slug + '.html'
    newHtml = indexHtml.to_html
    # Replace API Host and tenantName
    newHtml.gsub!('__API_URL__', API_URL)
    newHtml.gsub!('__TENANT_SUBDOMAIN__', ::Tenants::Tenant.find_by(legacy_id: tenant.id).slug)

    deploy_bucket.put_object(bucket: 'multi.itsmycargo.com', key: objKey, body: StringIO.new(newHtml), content_type: 'text/html', acl: 'public-read')

    create_distribution(tenant[:subdomain])
  end

  def create_distribution(subd)
    cloudfront = Aws::CloudFront::Client.new(
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region: Settings.aws.region
    )
    caller_reference = subd
    path = "#{subd}.html"
    domain = "#{subd}.itsmycargo.com"
    p path
    origin_id = 'S3-multi.itsmycargo.com'
    origin_domain = 'multi.itsmycargo.com.s3.amazonaws.com'
    origins = {
      quantity: 1,
      items: [
        { id: origin_id,
          domain_name: origin_domain,
          origin_path: '',
          s3_origin_config: { origin_access_identity: '' } }
      ]
    }
    default_cache_behavior = {
      target_origin_id: origin_id,
      forwarded_values: { query_string: false, cookies: { forward: 'none' } },
      trusted_signers: { enabled: false, quantity: 0 },
      viewer_protocol_policy: 'redirect-to-https',

      compress: true,

      min_ttl: 0
    }
    price_class = 'PriceClass_All'
    viewer_certificate = {
      cloud_front_default_certificate: false,
      ssl_support_method: 'sni-only',
      acm_certificate_arn: 'arn:aws:acm:us-east-1:003688427525:certificate/fa0a9dca-a804-4fee-8a97-a273f827b1c5'
    }
    comment = '-'

    resp = cloudfront.create_distribution \
      distribution_config: {
        caller_reference: caller_reference,
        origins: origins,
        aliases: {
          quantity: 1, # required
          items: [domain]
        },
        default_cache_behavior: default_cache_behavior,
        comment: comment,
        default_root_object: path,
        price_class: price_class,
        viewer_certificate: viewer_certificate,
        enabled: true,

        custom_error_responses: {
          quantity: 2, # required
          items: [
            {
              error_code: 403, # required
              response_page_path: "/#{subd}.html",
              response_code: '200',
              error_caching_min_ttl: 1
            },
            {
              error_code: 404, # required
              response_page_path: "/#{subd}.html",
              response_code: '200',
              error_caching_min_ttl: 1
            }
          ]
        }
      }
    @distribution_id          = resp[:distribution][:id]
    @distribution_domain_name = resp[:distribution][:domain_name]
    tenant = Tenant.find_by_subdomain(subd)
    tenant.web = {} unless tenant.web
    tenant.web['cloudfront'] = @distribution_id
    tenant.web['cloudfront_name'] = @distribution_domain_name
    tenant.save!
    new_record(domain, resp[:distribution][:domain_name])
  end

  def new_record(domain, cf_name) # rubocop:disable Metrics/MethodLength
    client = Aws::Route53::Client.new(
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region: Settings.aws.region
    )
    client.change_resource_record_sets(
      hosted_zone_id: 'Z3TZQVG8RI9CYN', # required
      change_batch: { # required
        comment: 'Multi Tenant System',
        changes: [ # required
          {
            action: 'CREATE', # required, accepts CREATE, DELETE, UPSERT
            resource_record_set: { # required
              name: domain, # required
              type: 'A', # required, accepts SOA, A, TXT, NS, CNAME, MX, NAPTR, PTR, SRV, SPF, AAAA

              alias_target: {
                hosted_zone_id: 'Z2FDTNDATAQYW2', # required
                dns_name: cf_name, # required
                evaluate_target_health: false # required
              }

            }
          }
        ]
      }
    )

    client.change_resource_record_sets(
      hosted_zone_id: 'Z3TZQVG8RI9CYN', # required
      change_batch: { # required
        comment: 'Hydra6',
        changes: [ # required
          {
            action: 'CREATE', # required, accepts CREATE, DELETE, UPSERT
            resource_record_set: { # required
              name: domain, # required
              type: 'AAAA', # required, accepts SOA, A, TXT, NS, CNAME, MX, NAPTR, PTR, SRV, SPF, AAAA

              alias_target: {
                hosted_zone_id: 'Z2FDTNDATAQYW2', # required
                dns_name: cf_name, # required
                evaluate_target_health: false # required
              }
            }
          }
        ]
      }
    )
  end

  def seed_demo_site(subdomain, tld) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    tenant = Tenant.find_by_subdomain(subdomain)
    tenant.users.destroy_all
    admin = tenant.users.new(
      role: Role.find_by_name('admin'),

      company_name: tenant.name,
      first_name: 'Admin',
      last_name: 'Admin',
      phone: '123456789',

      email: "admin@#{subdomain}.#{tld}",
      password: 'demo123456789',
      password_confirmation: 'demo123456789',

      confirmed_at: DateTime.new(2017, 1, 20)
    )

    admin.save!
    shipper = tenant.users.new(
      role: Role.find_by_name('shipper'),

      company_name: 'Example Shipper Company',
      first_name: 'John',
      last_name: 'Smith',
      phone: '123456789',

      email: "demo@#{::Tenants::Tenant.find_by(legacy_id: tenant.id).slug}.#{tld}",
      password: 'demo123456789',
      password_confirmation: 'demo123456789',

      confirmed_at: DateTime.new(2017, 1, 20)
    )
    # shipper.skip_confirmation!
    shipper.save!
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

  def invalidate(cloudfront_id, subdomain)
    cloudfront = Aws::CloudFront::Client.new(
      access_key_id: Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region: Settings.aws.region
    )
    invalidate_array = ["/#{subdomain}.html", '/config.js']
    invalidate_string = Time.now.to_i.to_s + '_subdomain'

    cloudfront.create_invalidation(
      distribution_id: cloudfront_id, # required
      invalidation_batch: { # required
        paths: { # required
          quantity: invalidate_array.length, # required
          items: invalidate_array
        },
        caller_reference: invalidate_string.to_s # required
      }
    )
  end

  def quotation_tool?(tenant)
    scope = ::Tenants::ScopeService.new(
      tenant: ::Tenants::Tenant.find_by(legacy_id: tenant&.id)
    ).fetch

    scope['open_quotation_tool'] || scope['closed_quotation_tool']
  end

end
