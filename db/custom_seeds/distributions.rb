# frozen_string_literal: true

subdomains = [
  { cloudfront: 'E1HIJBT7WVXAP3', subdomain: 'greencarrier', index: 'index.html' },
  { cloudfront: 'E20JU5F52LP1AZ', subdomain: 'demo', index: 'index.html' },
  { cloudfront: 'E3P24SVVXVUTZO', subdomain: 'nordicconsolidators' },
  { cloudfront: 'E2VR366CPGNLTC', subdomain: 'easyshipping' },
  { cloudfront: 'E1WJTKUIV6CYP3', subdomain: 'integrail' },
  { cloudfront: 'E1XPLYJA1HASN3', subdomain: 'eimskip' },
  { cloudfront: 'E42GZPFHU0WZO', subdomain: 'belglobe' },
  { cloudfront: 'E2IQ14Z9Z5JEGN', subdomain: 'greencarrier-sandbox' }
]

puts "Seeding Distributions..."

subdomains.each do |s|
  tenant = Tenant.find_by_subdomain(s[:subdomain])
  if tenant
    tenant.web = s
    tenant.save!
  end
end
