module MultiTenantTools
  include ExcelTools
  def test
    # tenant = JSON.parse(File.read("#{Rails.root}/test.json"))
    tenant =   {
      "theme": {
        "colors": {
          "primary": "#252D5C",
          "secondary": "##C42D35",
          "brightPrimary": "#4655aa",
          "brightSecondary": "#fc353e"
        },
        "logoLarge": "https://assets.itsmycargo.com/assets/logos/belglobe.png",
        "logoSmall": "https://assets.itsmycargo.com/assets/logos/belglobe.png"
      },
      "addresses": {
        "main": "Route de la Plaine 45, CH-1580 Avenches, SWITZERLAND"
      },
      "phones":{
        "main": "+41 (0)26 409 76 80",
        "support": "0173042031020"
      },
      "emails": {
        "sales": "info@belglobe.com",
        "support": "info@belglobe.com"
      },
      "subdomain": "belglobe",
      "name": "Belglobe",
      "scope": {
        "modes_of_transport": {
          "ocean": {
            "container": true,
            "cargo_item": true
          },
          "air": {
            "container": true,
            "cargo_item": true
          }
        }
      }
  }
    # new_site(tenant.to_h, true)
    seed_demo_site(tenant)
  end

  def update_indexes
    Tenant.all.each do |tenant|
        title = tenant.name + " | ItsMyCargo"
        favicon = "https://assets.itsmycargo.com/assets/favicon.ico"
        # indexHtml = Nokogiri::HTML(open("https://demo.itsmycargo.com/index.html"))
        indexHtml = Nokogiri::HTML(open(Rails.root.to_s + "/client/dist/index.html"))
        titles = indexHtml.xpath("//title")
        titles[0].content = title
        links = indexHtml.xpath("//link")

        links.each do |lnk|
          if lnk.attributes && lnk.attributes["href"] && lnk.attributes["href"].value == "https://assets.itsmycargo.com/assets/favicon.ico"
            lnk.content = favicon
          end
        end
          
          s3 = Aws::S3::Client.new(
            access_key_id: ENV['AWS_KEY'],
            secret_access_key: ENV['AWS_SECRET'],
            region: "us-east-1"
          )
          objKey = tenant["subdomain"] + ".html"
          newHtml = indexHtml.to_html
         File.open("blank.html", 'w') { |file|
          file.write(newHtml)
           }
        upFile = open("blank.html")
        s3.put_object(bucket: "multi.itsmycargo.com", key: objKey, body: upFile, content_type: 'text/html', acl: 'public-read')
        if tenant.web
          invalidate(tenant.web["cloudfront"], tenant.subdomain)
        end
      end
  end
  def new_site(tenant, is_demo)
        new_tenant = Tenant.create(tenant)
        title = tenant["name"] + " | ItsMyCargo"
        meta = tenant["meta"]
        favicon = tenant["favicon"] ? tenant["favicon"] : "https://assets.itsmycargo.com/assets/favicon.ico"
        indexHtml = Nokogiri::HTML(open("https://assets.itsmycargo.com/index.html"))
        titles = indexHtml.xpath("//title")
        titles[0].content = title
        metas = indexHtml.xpath("//meta")
        links = indexHtml.xpath("//link")

        links.each do |lnk|
          if lnk.attributes && lnk.attributes["href"] && lnk.attributes["href"].value == "https://assets.itsmycargo.com/assets/favicon.ico"
            lnk.content = favicon
          end
        end
          
          s3 = Aws::S3::Client.new(
            access_key_id: ENV['AWS_KEY'],
            secret_access_key: ENV['AWS_SECRET'],
            region: "us-east-1"
          )
          objKey = tenant["subdomain"] + ".html"
          newHtml = indexHtml.to_html
         File.open("blank.html", 'w') { |file|
          file.write(newHtml)
           }
        upFile = open("blank.html")
        s3.put_object(bucket: "multi.itsmycargo.com", key: objKey, body: upFile, content_type: 'text/html', acl: 'public-read')
        # uploader = S3FolderUpload.new('client/dist', 'multi.itsmycargo.com', ENV['AWS_KEY'], ENV['AWS_SECRET'])
        # uploader.upload!

        if is_demo
          seed_demo_site(tenant)
        end
        create_distribution(tenant["subdomain"])
    end
  def create_distribution(subd)
        cloudfront = Aws::CloudFront::Client.new(
            access_key_id: ENV['AWS_KEY'],
            secret_access_key: ENV['AWS_SECRET'],
            region: ENV['AWS_REGION']
          )
      caller_reference = subd
      path = "#{subd}.html"
      domain = "#{subd}.itsmycargo.com"
      p path
      origin_id = 'S3-multi.itsmycargo.com'
      origin_domain = 'multi.itsmycargo.com.s3.amazonaws.com'
      origins = { quantity: 1, items: [ { id: origin_id, domain_name: origin_domain, origin_path: '',
                                          s3_origin_config: { origin_access_identity: '' } } ] }
      default_cache_behavior = {
        target_origin_id: origin_id,
        forwarded_values: { query_string: false, cookies: { forward: 'none' } },
        trusted_signers: { enabled: false, quantity: 0 },
        viewer_protocol_policy: "redirect-to-https",

         compress: true,

        min_ttl: 0 }
      price_class = 'PriceClass_All'
      viewer_certificate = { cloud_front_default_certificate: false,
       ssl_support_method: "sni-only",
      acm_certificate_arn: "arn:aws:acm:us-east-1:003688427525:certificate/fa0a9dca-a804-4fee-8a97-a273f827b1c5" }
      comment = '-'
      enabled = true
      resp = cloudfront.create_distribution \
        distribution_config: {
          caller_reference: caller_reference,
          origins: origins,
           aliases: {
            quantity: 1, # required
            items: [domain],
          },
          default_cache_behavior: default_cache_behavior,
          comment: comment,
          default_root_object: path,
          price_class: price_class,
          viewer_certificate: viewer_certificate,
          enabled: true }
      @distribution_id          = resp[:distribution][:id]
      @distribution_domain_name = resp[:distribution][:domain_name]
      tenant = Tenant.find_by_subdomain(subd)
      if !tenant.web
        tenant.web = {}
      end
      tenant.web["cloudfront"] = @distribution_id
      tenant.web["cloudfront_name"] = @distribution_domain_name
      tenant.save!
      new_record(domain, resp[:distribution][:domain_name])
  end
  def new_record(domain, cf_name)
      client = Aws::Route53::Client.new(
        access_key_id: ENV['AWS_KEY'],
        secret_access_key: ENV['AWS_SECRET'],
        region: ENV['AWS_REGION']
      )
      resp = client.change_resource_record_sets({
        hosted_zone_id:  "Z3TZQVG8RI9CYN", # required
        change_batch: { # required
          comment: "Multi Tenant System",
          changes: [ # required
            {
              action: "CREATE", # required, accepts CREATE, DELETE, UPSERT
              resource_record_set: { # required
                name: domain, # required
                type: "A", # required, accepts SOA, A, TXT, NS, CNAME, MX, NAPTR, PTR, SRV, SPF, AAAA

                alias_target: {
                  hosted_zone_id: "Z2FDTNDATAQYW2", # required
                  dns_name: cf_name, # required
                  evaluate_target_health: false, # required
                }

              },
            },
          ],
        },
      })
      resp = client.change_resource_record_sets({
        hosted_zone_id: "Z3TZQVG8RI9CYN", # required
        change_batch: { # required
          comment: "Hydra6",
          changes: [ # required
            {
              action: "CREATE", # required, accepts CREATE, DELETE, UPSERT
              resource_record_set: { # required
                name: domain, # required
                type: "AAAA", # required, accepts SOA, A, TXT, NS, CNAME, MX, NAPTR, PTR, SRV, SPF, AAAA

                alias_target: {
                  hosted_zone_id: "Z2FDTNDATAQYW2", # required
                  dns_name: cf_name, # required
                  evaluate_target_health: false, # required
                }

              },
            },
          ],
        },
      })

    end
    def seed_demo_site(tenant_data)
        tld = tenant_data["web"] && tenant_data["web"]["tld"] ? tenant_data["web"]["tld"] : tenant_data["emails"]["support"].split('.')[1]
        tenant = Tenant.find_or_create_by!(tenant_data)
        tenant.users.destroy_all
        admin = tenant.users.new(
          role: Role.find_by_name('admin'),

          company_name: tenant.name,
          first_name: "Admin",
          last_name: "Admin",
          phone: "123456789",

          email: "admin@#{tenant.subdomain}.#{tld}",
          password: "demo123456789",
          password_confirmation: "demo123456789",

          confirmed_at: DateTime.new(2017, 1, 20)
        )
        
        admin.save!
        shipper = tenant.users.new(
          role: Role.find_by_name('shipper'),

          company_name: "Example Shipper Company",
          first_name: "John",
          last_name: "Smith",
          phone: "123456789",

          email: "demo@#{tenant.subdomain}.#{tld}",
          password: "demo123456789",
          password_confirmation: "demo123456789",

          confirmed_at: DateTime.new(2017, 1, 20)
        )
        # shipper.skip_confirmation!
        shipper.save!
        # Create dummy locations for shipper
        dummy_locations = [
          {
            street: "Kehrwieder",
            street_number: "2",
            zip_code: "20457",
            city: "Hamburg",
            country:"Germany"
          },
          {
            street: "Carer del Cid",
            street_number: "13",
            zip_code: "08001",
            city: "Barcelona",
            country:"Spain"
          },
          {
            street: "College Rd",
            street_number: "1",
            zip_code: "PO1 3LX",
            city: "Portsmouth",
            country:"United Kingdom"
          },
          {
            street: "Tuna St",
            street_number: "64",
            zip_code: "90731",
            city: "San Pedro",
            country:"USA"
          }
        ]

        dummy_locations.each do |l|
          loc = Location.create_and_geocode(l)
          shipper.locations << loc
        end

        # Create dummy contacts for shipper address book
        dummy_contacts = [
          {
            company_name: "Example Shipper Company",
            first_name: "John",
            last_name: "Smith",
            phone: "123456789",
            email: "demo@#{tenant.subdomain}.com",
          },
          {
            company_name: "Another Example Shipper Company",
            first_name: "Jane",
            last_name: "Doe",
            phone: "123456789",
            email: "jane@doe.com"
          },
          {
            company_name: "Yet Another Example Shipper Company",
            first_name: "Javier",
            last_name: "Garcia",
            phone: "0034123456789",
            email: "javi@shipping.com"
          },
          {
            company_name: "Forwarder Company",
            first_name: "Gertrude",
            last_name: "Hummels",
            phone: "0049123456789",
            email: "gerti@fwd.com"
          },
          {
            company_name: "Another Forwarder Company",
            first_name: "Jerry",
            last_name: "Lin",
            phone: "001123456789",
            email: "jerry@fwder2.com"
          }
        ]

        dummy_contacts.each_with_index do |contact, i|
          loc = Location.find_or_create_by(dummy_locations[i])
          contact[:location_id] = loc.id
          shipper.contacts.create(contact)
        end

        vehicle_types = [
          'ocean_default',
          'rail_default',
          'air_default',
          'truck_default'
        ]
        cargo_types = [
          'dry_goods',
          'liquid_bulk',
          'gas_bulk',
          'any'
        ]
        load_types = [
          'fcl_20f',
          'fcl_40f',
          'fcl_40f_hq',
          'lcl'
        ]

        vehicle_types.each do |vt|
          mot = vt.split('_')[0]
          vehicle = Vehicle.create(name: vt, mode_of_transport: mot)
          tenant.tenant_vehicles.create(name: vt, mode_of_transport: mot, vehicle_id: vehicle.id)

          load_types.each do |lt|
            cargo_types.each do |ct|
              vehicle.transport_categories.create(mode_of_transport: mot, cargo_class: lt, name: ct )
            end
          end
        end
        puts "# Overwrite hubs from excel sheet"
        hubs = File.open("#{Rails.root}/db/dummydata/1_hubs.xlsx")
        req = {"xlsx" => hubs}
        overwrite_hubs(req, shipper)

        # # Overwrite service charges from excel sheet
        puts "# Overwrite service charges from excel sheet"
        service_charges = File.open("#{Rails.root}/db/dummydata/2_service_charges.xlsx")
        req = {"xlsx" => service_charges}
        overwrite_service_charges(req, shipper)

        # Overwrite dedicated pricings from excel sheet.
        #   If dedicated == true, shipper.id is automatically inserted.
        puts "# Overwrite dedicated pricings from excel sheet."
        public_pricings = File.open("#{Rails.root}/db/dummydata/new_public_ocean_ptp_rates.xlsx")
        req = {"xlsx" => public_pricings}
        overwrite_mongo_lcl_pricings(req, dedicated = true, shipper)

        # # Overwrite public pricings from excel sheet
        puts "# Overwrite public pricings from excel sheet"
        public_pricings = File.open("#{Rails.root}/db/dummydata/new_public_ocean_ptp_rates.xlsx")
        req = {"xlsx" => public_pricings}
        overwrite_mongo_lcl_pricings(req, dedicated = false, shipper)

        puts "# Overwrite MAERSK pricings from excel sheet"
        public_pricings = File.open("#{Rails.root}/db/dummydata/mini_MAERSK_FCL.xlsx")
        req = {"xlsx" => public_pricings}
        overwrite_mongo_maersk_fcl_pricings(req, dedicated = false, shipper)

        # OLD, SQL DB method (!): Overwrite public pricings from excel sheet
        # public_pricings = File.open("#{Rails.root}/db/dummydata/3_PUBLIC_ocean_ptp_rates.xlsx")
        # req = {"xlsx" => public_pricings}
        # overwrite_main_carriage_rates(req, false, shipper)
        # shipper = User.find_by_email('demo@greencarrier.com')

        # Overwrite trucking data from excel sheet
        puts "# Overwrite trucking data from excel sheet"
        trucking = File.open("#{Rails.root}/db/dummydata/5_trucking_rates_per_city.xlsx")
        req = {"xlsx" => trucking}
        overwrite_trucking_rates(req, shipper)

        trucking = File.open("#{Rails.root}/db/dummydata/shanghai_trucking.xlsx")
        req = {"xlsx" => trucking}
        overwrite_city_trucking_rates(req, shipper)

        tenant.update_route_details()
    end
    def invalidate(cfId, subdomain)
      cloudfront = Aws::CloudFront::Client.new(
          access_key_id: ENV['AWS_KEY'],
        secret_access_key: ENV['AWS_SECRET'],
        region: ENV['AWS_REGION']
        )
      invalArray = ["/#{subdomain}.html"];
      invalStr = Time.now.to_i.to_s + "_subdomain"
       resp = cloudfront.create_invalidation({
          distribution_id: cfId, # required
          invalidation_batch: { # required
            paths: { # required
              quantity: invalArray.length, # required
              items: invalArray,
            },
            caller_reference: invalStr.to_s, # required
          },
        })

    end
end