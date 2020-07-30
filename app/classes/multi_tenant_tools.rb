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

  def create_new_tenant_site(subdomains)
    subdomains.each do |subdomain|
      json_data = JSON.parse(
        asset_bucket.get_object(bucket: 'assets.itsmycargo.com', key: "data/#{subdomain}/#{subdomain}.json").body.read
      ).deep_symbolize_keys
      new_site(json_data, false)
    end
  end

  def quick_seed(subdomain)
    puts 'Seed prcings'
    PricingSeeder.perform(subdomain: subdomain)
  end
end
