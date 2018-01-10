module MultiTenantTools
  def test
    tenant = JSON.parse(File.read("#{Rails.root}/test.json"))
    newSiteFn(tenant)
  end
  def newSiteFn(tenant)
        # new_tenant = Tenant.create(tenant)
        title = tenant["name"] + " | ItsMyCargo"
        meta = tenant["meta"]
        favicon = tenant["favicon"] ? tenant["favicon"] : "https://assets.itsmycargo.com/assets/favicon.ico"
        indexHtml = Nokogiri::HTML(File.open('client/dist/index.html'))
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
        # create_distribution(tenant["subdomain"])
        uploader = S3FolderUpload.new('client/dist', 'multi.itsmycargo.com', ENV['AWS_KEY'], ENV['AWS_SECRET'])
        uploader.upload!
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
    def new_front(sudb)
      bkt_name = subd * ".tktr.es"
      resp = client.create_distribution({
        distribution_config: { # required
          caller_reference: bkt_name, # required
          aliases: {
            quantity: 1, # required
            items: [bkt_name],
          },
          default_root_object: "index.html",
          origins: { # required
            quantity: 1, # required
            items: [
              {
                id: "default", # required
                domain_name: "string", # required
                origin_path: "",
                custom_headers: {
                  quantity: 1, # required
                  items: [
                    {
                      header_name: "string", # required
                      header_value: "string", # required
                    },
                  ],
                },
                s3_origin_config: {
                  origin_access_identity: "string", # required
                },
                custom_origin_config: {
                  http_port: 1, # required
                  https_port: 1, # required
                  origin_protocol_policy: "http-only", # required, accepts http-only, match-viewer, https-only
                  origin_ssl_protocols: {
                    quantity: 1, # required
                    items: ["SSLv3"], # required, accepts SSLv3, TLSv1, TLSv1.1, TLSv1.2
                  },
                },
              },
            ],
          },
          default_cache_behavior: { # required
            target_origin_id: "string", # required
            forwarded_values: { # required
              query_string: false, # required
              cookies: { # required
                forward: "none", # required, accepts none, whitelist, all
                whitelisted_names: {
                  quantity: 1, # required
                  items: ["string"],
                },
              },
              headers: {
                quantity: 1, # required
                items: ["string"],
              },
              query_string_cache_keys: {
                quantity: 1, # required
                items: ["string"],
              },
            },
            trusted_signers: { # required
              enabled: false, # required
              quantity: 1, # required
              items: ["string"],
            },
            viewer_protocol_policy: "allow-all", # required, accepts allow-all, https-only, redirect-to-https
            min_ttl: 1, # required
            allowed_methods: {
              quantity: 1, # required
              items: ["GET"], # required, accepts GET, HEAD, POST, PUT, PATCH, OPTIONS, DELETE
              cached_methods: {
                quantity: 1, # required
                items: ["GET"], # required, accepts GET, HEAD, POST, PUT, PATCH, OPTIONS, DELETE
              },
            },
            smooth_streaming: false,
            default_ttl: 1,
            max_ttl: 1,
            compress: false,
            lambda_function_associations: {
              quantity: 1, # required
              items: [
                {
                  lambda_function_arn: "string",
                  event_type: "viewer-request", # accepts viewer-request, viewer-response, origin-request, origin-response
                },
              ],
            },
          },
          cache_behaviors: {
            quantity: 1, # required
            items: [
              {
                path_pattern: "string", # required
                target_origin_id: "string", # required
                forwarded_values: { # required
                  query_string: false, # required
                  cookies: { # required
                    forward: "none", # required, accepts none, whitelist, all
                    whitelisted_names: {
                      quantity: 1, # required
                      items: ["string"],
                    },
                  },
                  headers: {
                    quantity: 1, # required
                    items: ["string"],
                  },
                  query_string_cache_keys: {
                    quantity: 1, # required
                    items: ["string"],
                  },
                },
                trusted_signers: { # required
                  enabled: false, # required
                  quantity: 1, # required
                  items: ["string"],
                },
                viewer_protocol_policy: "allow-all", # required, accepts allow-all, https-only, redirect-to-https
                min_ttl: 1, # required
                allowed_methods: {
                  quantity: 1, # required
                  items: ["GET"], # required, accepts GET, HEAD, POST, PUT, PATCH, OPTIONS, DELETE
                  cached_methods: {
                    quantity: 1, # required
                    items: ["GET"], # required, accepts GET, HEAD, POST, PUT, PATCH, OPTIONS, DELETE
                  },
                },
                smooth_streaming: false,
                default_ttl: 1,
                max_ttl: 1,
                compress: false,
                lambda_function_associations: {
                  quantity: 1, # required
                  items: [
                    {
                      lambda_function_arn: "string",
                      event_type: "viewer-request", # accepts viewer-request, viewer-response, origin-request, origin-response
                    },
                  ],
                },
              },
            ],
          },
          custom_error_responses: {
            quantity: 1, # required
            items: [
              {
                error_code: 1, # required
                response_page_path: "string",
                response_code: "string",
                error_caching_min_ttl: 1,
              },
            ],
          },
          comment: "string", # required
          logging: {
            enabled: false, # required
            include_cookies: false, # required
            bucket: "string", # required
            prefix: "string", # required
          },
          price_class: "PriceClass_100", # accepts PriceClass_100, PriceClass_200, PriceClass_All
          enabled: false, # required
          viewer_certificate: {
            cloud_front_default_certificate: false,
            iam_certificate_id: "string",
            acm_certificate_arn: "string",
            ssl_support_method: "sni-only", # accepts sni-only, vip
            minimum_protocol_version: "SSLv3", # accepts SSLv3, TLSv1
            certificate: "string",
            certificate_source: "cloudfront", # accepts cloudfront, iam, acm
          },
          restrictions: {
            geo_restriction: { # required
              restriction_type: "blacklist", # required, accepts blacklist, whitelist, none
              quantity: 1, # required
              items: ["string"],
            },
          },
          web_acl_id: "string",
          http_version: "http1.1", # accepts http1.1, http2
          is_ipv6_enabled: false,
        },
      })

    end
    def invalidate(cfId, subdomain)
      creds = YAML.load(File.read('./config/application.yml'))
      cloudfront = Aws::CloudFront::Client.new(
          access_key_id: ENV['AWS_KEY'],
        secret_access_key: ENV['AWS_SECRET'],
        region: ENV['AWS_REGION']
        )
      invalArray = ["#{subdomain}.html"];
      invalStr = Time.now.to_i
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