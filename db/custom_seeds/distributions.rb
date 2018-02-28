subdomains =  [
  {cloudfront: "E20JU5F52LP1AZ", subdomain: "greencarrier", index: "index.html"},
  {cloudfront: "E20JU5F52LP1AZ", subdomain: "demo", index: "index.html"},
  {cloudfront: "E3P24SVVXVUTZO", subdomain: "nordicconsolidators"},
  {cloudfront: "E2VR366CPGNLTC", subdomain: "easyshipping"},
  {cloudfront: "E1WJTKUIV6CYP3", subdomain: "integrail"}
];

subdomains.each do |s|
  tenant = Tenant.find_by_subdomain(s[:subdomain])
  if tenant
    tenant.web = s
    tenant.save!
  end
end