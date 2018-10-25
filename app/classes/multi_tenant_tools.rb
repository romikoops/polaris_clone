# frozen_string_literal: true

module MultiTenantTools
  include ExcelTools
  require_relative '../../db/seed_classes/vehicle_seeder.rb'
  require_relative '../../db/seed_classes/pricing_seeder.rb'
  require_relative '../../db/seed_classes/tenant_seeder.rb'

  API_URL = 'https://api2.itsmycargo.com'
  DEV_API_URL = 'https://gamma.itsmycargo.com'

  def s3_signer
    Aws::S3::Presigner.new(
      access_key_id:     Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key
    )
  end

  def deploy_bucket
    Aws::S3::Client.new(
      access_key_id:     Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region: 'us-east-1'
    )
  end

  def asset_bucket
    Aws::S3::Client.new(
      access_key_id:     Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key
    )
  end

  def update_indexes
    Tenant.all.each do |tenant|
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
      newHtml.gsub!('__TENANT_SUBDOMAIN__', tenant.subdomain)

      deploy_bucket.put_object(bucket: 'multi.itsmycargo.com', key: objKey, body: StringIO.new(newHtml), content_type: 'text/html', acl: 'public-read')
      invalidate(tenant.web['cloudfront'], tenant.subdomain) if tenant.web && tenant.web['cloudfront']
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
      newHtml.gsub!('__TENANT_SUBDOMAIN__', tenant.subdomain)

      deploy_bucket.put_object(bucket: 'multi.itsmycargo.com', key: objKey, body: StringIO.new(newHtml), content_type: 'text/html', acl: 'public-read')
      invalidate(tenant.web['cloudfront'], tenant.subdomain) if tenant.web && tenant.web['cloudfront']
    end
  end

  def create_sandboxes
    sandbox_tenants = []
    Tenant.all.map do |t|
      sandbox_tenants << t if t.subdomain.include? 'sandbox'
    end

    sandbox_tenants.each do |st|
      new_site_from_tenant(st)
    end
  end

  def update_tenant_jsons
    @json_data = JSON.parse(File.read("#{Rails.root}/db/dummydata/tenants.json"))
    @json_data.each do |tenant|
      subdomain = tenant['subdomain']
      File.open("#{Rails.root}/db/dummydata/#{subdomain}/#{subdomain}.json", 'w') { |file| file.write(tenant.to_json) }
      objKey = "data/#{subdomain}/#{subdomain}.json"
      upFile = File.open("#{Rails.root}/db/dummydata/#{subdomain}/#{subdomain}.json")
      asset_bucket.put_object(bucket: 'assets.itsmycargo.com', key: objKey, body: upFile, content_type: 'application/json', acl: 'private')
    end
  end

  def sync_tenant_jsons
    @json_data = JSON.parse(File.read("#{Rails.root}/db/dummydata/tenants.json"))
    @new_data = []
    @json_data.each do |tenant|
      subdomain = tenant['subdomain']
      tenant_data = JSON.parse(
        S3.get_object(bucket: 'assets.itsmycargo.com', key: "data/#{subdomain}/#{subdomain}.json").body.read
      )
      @new_data << tenant_data
    end
    File.open("#{Rails.root}/db/dummydata/tenants.json", 'w') { |file| file.write(@new_data.to_json) }
  end

  def update_tenant_from_json(subdomain)
    json_data = JSON.parse(
      asset_bucket.get_object(bucket: 'assets.itsmycargo.com', key: "data/#{subdomain}/#{subdomain}.json").body.read
    )

    tenant = Tenant.find_by_subdomain(json_data['subdomain'])

    # Handle "other_data" part of the hash (hacky)
    other_data = json_data.delete('other_data') || {}
    TenantSeeder.update_cargo_item_types!(tenant, other_data['cargo_item_types'])
    TenantSeeder.update_tenant_incoterms!(tenant, other_data['incoterms'])

    tenant.update_attributes(json_data)
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
    new_tenant = Tenant.create(tenant)
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
    tenant = Tenant.find_by_subdomain(subdomain)
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
      access_key_id:     Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region:            'us-east-1'
    )
    objKey = tenant.subdomain + '.html'
    newHtml = indexHtml.to_html
    # Replace API Host and tenantName
    newHtml.gsub!('__API_URL__', API_URL)
    newHtml.gsub!('__TENANT_SUBDOMAIN__', tenant.subdomain)

    deploy_bucket.put_object(bucket: 'multi.itsmycargo.com', key: objKey, body: StringIO.new(newHtml), content_type: 'text/html', acl: 'public-read')

    create_distribution(tenant[:subdomain])
  end

  def create_distribution(subd)
    cloudfront = Aws::CloudFront::Client.new(
      access_key_id:     Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region:            Settings.aws.region
    )
    caller_reference = subd
    path = "#{subd}.html"
    domain = "#{subd}.itsmycargo.com"
    p path
    origin_id = 'S3-multi.itsmycargo.com'
    origin_domain = 'multi.itsmycargo.com.s3.amazonaws.com'
    origins = {
      quantity: 1,
      items:    [
        { id:               origin_id,
          domain_name:      origin_domain,
          origin_path:      '',
          s3_origin_config: { origin_access_identity: '' } }
      ]
    }
    default_cache_behavior = {
      target_origin_id:       origin_id,
      forwarded_values:       { query_string: false, cookies: { forward: 'none' } },
      trusted_signers:        { enabled: false, quantity: 0 },
      viewer_protocol_policy: 'redirect-to-https',

      compress:               true,

      min_ttl:                0
    }
    price_class = 'PriceClass_All'
    viewer_certificate = { cloud_front_default_certificate: false,
                           ssl_support_method:              'sni-only',
                           acm_certificate_arn:             'arn:aws:acm:us-east-1:003688427525:certificate/fa0a9dca-a804-4fee-8a97-a273f827b1c5' }
    comment = '-'
    enabled = true
    resp = cloudfront.create_distribution \
      distribution_config: {
        caller_reference:       caller_reference,
        origins:                origins,
        aliases:                {
          quantity: 1, # required
          items:    [domain]
        },
        default_cache_behavior: default_cache_behavior,
        comment:                comment,
        default_root_object:    path,
        price_class:            price_class,
        viewer_certificate:     viewer_certificate,
        enabled:                true,

        custom_error_responses: {
          quantity: 2, # required
          items:    [
            {
              error_code:            403, # required
              response_page_path:    "/#{subd}.html",
              response_code:         '200',
              error_caching_min_ttl: 1
            },
            {
              error_code:            404, # required
              response_page_path:    "/#{subd}.html",
              response_code:         '200',
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

  def new_record(domain, cf_name)
    client = Aws::Route53::Client.new(
      access_key_id:     Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region:            Settings.aws.region
    )
    resp = client.change_resource_record_sets(
      hosted_zone_id: 'Z3TZQVG8RI9CYN', # required
      change_batch:   { # required
        comment: 'Multi Tenant System',
        changes: [ # required
          {
            action:              'CREATE', # required, accepts CREATE, DELETE, UPSERT
            resource_record_set: { # required
              name:         domain, # required
              type:         'A', # required, accepts SOA, A, TXT, NS, CNAME, MX, NAPTR, PTR, SRV, SPF, AAAA

              alias_target: {
                hosted_zone_id:         'Z2FDTNDATAQYW2', # required
                dns_name:               cf_name, # required
                evaluate_target_health: false, # required
              }

            }
          }
        ]
      }
    )
    resp = client.change_resource_record_sets(
      hosted_zone_id: 'Z3TZQVG8RI9CYN', # required
      change_batch:   { # required
        comment: 'Hydra6',
        changes: [ # required
          {
            action:              'CREATE', # required, accepts CREATE, DELETE, UPSERT
            resource_record_set: { # required
              name:         domain, # required
              type:         'AAAA', # required, accepts SOA, A, TXT, NS, CNAME, MX, NAPTR, PTR, SRV, SPF, AAAA

              alias_target: {
                hosted_zone_id:         'Z2FDTNDATAQYW2', # required
                dns_name:               cf_name, # required
                evaluate_target_health: false, # required
              }
            }
          }
        ]
      }
    )
  end

  def seed_demo_site(subdomain, tld)
    tenant = Tenant.find_by_subdomain(subdomain)
    tenant.users.destroy_all
    admin = tenant.users.new(
      role:                  Role.find_by_name('admin'),

      company_name:          tenant.name,
      first_name:            'Admin',
      last_name:             'Admin',
      phone:                 '123456789',

      email:                 "admin@#{subdomain}.#{tld}",
      password:              'demo123456789',
      password_confirmation: 'demo123456789',

      confirmed_at:          DateTime.new(2017, 1, 20)
    )

    admin.save!
    shipper = tenant.users.new(
      role:                  Role.find_by_name('shipper'),

      company_name:          'Example Shipper Company',
      first_name:            'John',
      last_name:             'Smith',
      phone:                 '123456789',

      email:                 "demo@#{tenant.subdomain}.#{tld}",
      password:              'demo123456789',
      password_confirmation: 'demo123456789',

      confirmed_at:          DateTime.new(2017, 1, 20)
    )
    # shipper.skip_confirmation!
    shipper.save!
    # Create dummy locations for shipper
    dummy_locations = [
      {
        street:        'Kehrwieder',
        street_number: '2',
        zip_code:      '20457',
        city:          'Hamburg',
        country:       'Germany'
      },
      {
        street:        'Carer del Cid',
        street_number: '13',
        zip_code:      '08001',
        city:          'Barcelona',
        country:       'Spain'
      },
      {
        street:        'College Rd',
        street_number: '1',
        zip_code:      'PO1 3LX',
        city:          'Portsmouth',
        country:       'United Kingdom'
      },
      {
        street:        'Tuna St',
        street_number: '64',
        zip_code:      '90731',
        city:          'San Pedro',
        country:       'USA'
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
        first_name:   'John',
        last_name:    'Smith',
        phone:        '123456789',
        email:        "demo@#{tenant.subdomain}.com"
      },
      {
        company_name: 'Another Example Shipper Company',
        first_name:   'Jane',
        last_name:    'Doe',
        phone:        '123456789',
        email:        'jane@doe.com'
      },
      {
        company_name: 'Yet Another Example Shipper Company',
        first_name:   'Javier',
        last_name:    'Garcia',
        phone:        '0034123456789',
        email:        'javi@shipping.com'
      },
      {
        company_name: 'Forwarder Company',
        first_name:   'Gertrude',
        last_name:    'Hummels',
        phone:        '0049123456789',
        email:        'gerti@fwd.com'
      },
      {
        company_name: 'Another Forwarder Company',
        first_name:   'Jerry',
        last_name:    'Lin',
        phone:        '001123456789',
        email:        'jerry@fwder2.com'
      }
    ]

    dummy_contacts.each_with_index do |contact, i|
      loc = Location.find_or_create_by(dummy_locations[i])
      contact[:location_id] = loc.id
      shipper.contacts.create(contact)
    end

    puts 'Seed vehicles'
    VehicleSeeder.perform

    puts 'Seed prcings'
    PricingSeeder.perform
  end

  def quick_seed(subdomain)
    puts 'Seed prcings'
    PricingSeeder.perform(subdomain: subdomain)
  end

  def do_customs(subdomain)
    t = Tenant.find_by_subdomain(subdomain)
    shipper = t.users.shipper.first
    puts '# Overwrite Local Charges From Sheet'
    local_charges = File.open("#{Rails.root}/db/dummydata/fake_local_charges.xlsx")
    req = { 'xlsx' => local_charges }
    ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform
  end

  def quick_fix(subdomain)
    t = Tenant.find_by_subdomain(subdomain)
    shipper = t.users.shipper.first
    public_pricings = File.open("#{Rails.root}/db/dummydata/new_public_ocean_ptp_rates.xlsx")
    req = { 'xlsx' => public_pricings }
    overwrite_mongo_lcl_pricings(req, dedicated = false, shipper)
    overwrite_mongo_lcl_pricings(req, dedicated = true, shipper)
  end

  def invalidate(cfId, subdomain)
    cloudfront = Aws::CloudFront::Client.new(
      access_key_id:     Settings.aws.access_key_id,
      secret_access_key: Settings.aws.secret_access_key,
      region:            Settings.aws.region
    )
    invalArray = ["/#{subdomain}.html", '/config.js']
    invalStr = Time.now.to_i.to_s + '_subdomain'
    resp = cloudfront.create_invalidation(
      distribution_id:    cfId, # required
      invalidation_batch: { # required
        paths:            { # required
          quantity: invalArray.length, # required
          items:    invalArray
        },
        caller_reference: invalStr.to_s, # required
      }
    )
  end
end
