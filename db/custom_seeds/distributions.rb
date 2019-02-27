# frozen_string_literal: true

subdomains = [
  { cloudfront: 'E1HIJBT7WVXAP3', subdomain: 'greencarrier', index: 'index.html' },
  { cloudfront: 'E19KMYH87T6B3G', subdomain: 'demo', index: 'index.html' },
  { cloudfront: 'E3P24SVVXVUTZO', subdomain: 'nordicconsolidators' },
  { cloudfront: 'E2VR366CPGNLTC', subdomain: 'easyshipping' },
  { cloudfront: 'E1WJTKUIV6CYP3', subdomain: 'integrail' },
  { cloudfront: 'E1XPLYJA1HASN3', subdomain: 'eimskip' },
  { cloudfront: 'E42GZPFHU0WZO', subdomain: 'belglobe' },
  { cloudfront: 'E2IQ14Z9Z5JEGN', subdomain: 'greencarrier-sandbox' },
  { cloudfront: 'E1AMKNHZUXL589', subdomain: 'speedtrans' },
  { cloudfront: 'EMDO0NOOSGVWK', subdomain: 'trucking' },
  { cloudfront: 'E4GVOGV46JUC2', subdomain: 'speedtrans-sandbox' },
  { cloudfront: 'E2JGC82SATBA4', subdomain: 'fivestar' },
  { cloudfront: 'EP3724MQWNMFU', subdomain: 'gateway' },
  { cloudfront: 'E1FB49BKWKCE7D', subdomain: 'normanglobal' },
  { cloudfront: 'E1LH7CIJ17ZFOV', subdomain: 'saco' },
  { cloudfront: 'EFYAT2X9Z0TQY', subdomain: 'schryver' }
]

puts 'Seeding Distributions...'

subdomains.each do |s|
  tenant = Tenant.find_by_subdomain(s[:subdomain])
  if tenant
    tenant.web = s
    tenant.save!
  end
end
