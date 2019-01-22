# frozen_string_literal: true

include ExcelTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w(schryver schryver-sandbox)
subdomains.each do |sub|
  # # Tenant.all.each do |tenant|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  tenant.itineraries.destroy_all
  tenant.local_charges.destroy_all
  tenant.customs_fees.destroy_all
  tenant.trucking_pricings.delete_all
  HubTrucking.where(hub_id: tenant.hubs).delete_all
  tenant.hubs.destroy_all

  # #   # # # # #Overwrite hubs from excel sheet
  puts '# Overwrite hubs from excel sheet'
  hubs = 'data/schryver/schryver__hubs.xlsx'
  req = { 'key' => hubs }
  ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  public_pricings = 'data/schryver/schryver__freight_rates.xlsx'
  req = { 'key' => public_pricings }
  ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform

  # # # # #   # # # # # Overwrite public pricings from excel sheet

  # puts "# Overwrite Local Charges From Sheet"
  local_charges = 'data/schryver/schryver__local_charges.xlsx'
  req = { 'key' => local_charges }
  ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform
  # #   # # # # # # Overwrite trucking data from excel sheet

  path = 'data/schryver/ftl_rates.xlsx'
  ftl_data = DataParser::Schryver::FtlParser.new(path: path,
                                                 _user: shipper).perform

  ftl_results = DataInserter::Schryver::FtlInserter.new(rates: ftl_data,
                                                        _user: shipper,
                                                        tenant: tenant).perform
  puts 'Hamburg Port'
  hub = tenant.hubs.find_by_name('Hamburg Port')
  trucking = 'data/schryver/schryver__trucking_ltl__hamburg_port.xlsx'
  req = { 'key' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  trucking = 'data/schryver/schryver__trucking_ftl__hamburg_port.xlsx'
  req = { 'key' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  # trucking = 'data/schryver/schryver__trucking_ftl__hamburg_port.xlsx'
  # req = { 'key' => trucking }
  # # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  puts 'Bremerhaven Port'
  hub = tenant.hubs.find_by_name('Bremerhaven Port')
  trucking = 'data/schryver/schryver__trucking_ltl__hamburg_port.xlsx'
  req = { 'key' => trucking }
  # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  # trucking = 'data/schryver/schryver__trucking_ftl__bremerhaven_port.xlsx'
  # req = { 'key' => trucking }
  # # overwrite_zonal_trucking_rates_by_hub(req, shipper, hub.id)
  # ExcelTool::OverrideTruckingRateByHub.new(params: req, _user: shipper, hub_id: hub.id).perform
  users = [
    {
      role: Role.find_by_name('shipper'),
      company_name: 'Schryver Ecuador',
      first_name: 'Admin',
      last_name: 'Schryver',
      phone: '+59322900621',
      email: 'quito@schryver.com',
      password: 'schryver@quito',
      password_confirmation: 'schryver@quito',
      confirmed_at: DateTime.new(2017, 1, 20)
    },
    {
      role: Role.find_by_name('shipper'),
      company_name: 'Schryver Mexico',
      first_name: 'Admin',
      last_name: 'Schryver',
      phone: '+528186255250',
      email: 'monterrey@schryver.com',
      password: 'schryver@monterrey',
      password_confirmation: 'schryver@monterrey',
      confirmed_at: DateTime.new(2017, 1, 20)
    },
    {
      role: Role.find_by_name('shipper'),
      company_name: 'Schryver GbmH',
      first_name: 'Admin',
      last_name: 'Schryver',
      phone: '+4940236330',
      email: 'info@schryver.com',
      password: 'schryver@admin',
      password_confirmation: 'schryver@admin',
      confirmed_at: DateTime.new(2017, 1, 20)
    },
    {
      role: Role.find_by_name('shipper'),
      company_name: 'REMA TIP TOP AG',
      first_name: 'Admin',
      last_name: 'Schryver',
      phone: '+49 8121 707-10362',
      email: 'Doris.Wiechers@tiptop.de',
      password: 'schryver@tiptop',
      password_confirmation: 'schryver@tiptop',
      confirmed_at: DateTime.new(2017, 1, 20)
    }
  ]

  users.each do |user_data|
    existing_user = tenant.users.find_by_email(user_data[:email])
    tenant.users.create!(user_data) unless existing_user
  end
end
