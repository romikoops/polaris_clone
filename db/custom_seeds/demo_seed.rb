# frozen_string_literal: false

include ExcelTools
include ShippingTools
# subdomains = %w(demo greencarrier easyshipping hartrodt)
subdomains = %w(speedtrans)
subdomains.each do |sub|
  tenant = Tenant.find_by_subdomain(sub)

  shipper = tenant.users.shipper.first
  DataValidator::PricingValidator.new(tenant: tenant.id, user: shipper, key: 'data/speedtrans/pricing_expected_20180927_speedtrans.xlsx').perform
  # tenant.itineraries.destroy_all
  # tenant.local_charges.destroy_all
  # tenant.customs_fees.destroy_all
  # tenant.trucking_pricings.delete_all
  # HubTrucking.where(hub_id: tenant.hubs).destroy_all
  # tenant.hubs.destroy_all

  # # #   # # # # #Overwrite hubs from excel sheet
  # puts '# Overwrite hubs from excel sheet'
  # hubs = 'data/schryver/schryver__hubs.xlsx'
  # req = { 'key' => hubs }
  # ExcelTool::HubsOverwriter.new(params: req, _user: shipper).perform

  # public_pricings = 'data/schryver/schryver__freight_rates.xlsx'
  # req = { 'key' => public_pricings }
  # ExcelTool::FreightRatesOverwriter.new(params: req, _user: shipper, generate: true).perform

  # # # # # #   # # # # # Overwrite public pricings from excel sheet

  # # puts "# Overwrite Local Charges From Sheet"
  # local_charges = 'data/schryver/schryver__local_charges.xlsx'
  # req = { 'key' => local_charges }
  # ExcelTool::OverwriteLocalCharges.new(params: req, user: shipper).perform
  # # #   # # # # # # Overwrite trucking data from excel sheet

  # path = 'data/schryver/ftl_rates.xlsx'
  # ftl_data = DataParser::Schryver::FtlParser.new(path: path,
  #                                                _user: shipper).perform

  # ftl_results = DataInserter::Schryver::FtlInserter.new(rates: ftl_data,
  #                                                       _user: shipper,
  #                                                       tenant: tenant).perform
  # imp_hubs = DataInserter::PfcNordic::HubInserter.new(data: imp_data,
  #   tenant: tenant,
  #   counterpart_hub: 'Copenhagen Port',
  #   _user: shipper,
  #   hub_type: 'ocean',
  #   direction: 'import').perform

  # res = DataInserter::PfcNordic::RateInserter.new(rates: imp_data,
  #   tenant: tenant,
  #   counterpart_hub: 'Copenhagen Port',
  #   direction: 'import',
  #   cargo_class: 'lcl').perform

  # path = "#{Rails.root}/db/dummydata/easyshipping/pfc_export.xlsx"

  # ex_data = DataParser::PfcNordic::SheetParserExport.new(
  #   path: path,
  #   _user: shipper,
  #   counterpart_hub_name: 'Copenhagen Port',
  #   hub_type: 'ocean',
  #   input_language: 'de',
  #   cargo_class: 'lcl',
  #   load_type: 'cargo_item'
  #   ).perform

  # ex_hubs = DataInserter::PfcNordic::HubInserter.new(
  #   data: ex_data,
  #   tenant: tenant,
  #   counterpart_hub: 'Copenhagen Port',
  #   _user: shipper,
  #   hub_type: 'ocean',
  #   direction: 'export').perform

  # res = DataInserter::PfcNordic::RateInserter.new(
  #   rates: ex_data,
  #   tenant: tenant,
  #   counterpart_hub: 'Copenhagen Port',
  #   direction: 'export',
  #   cargo_class: 'lcl',
  #   input_language: 'de',).perform

  # local_charges = File.open("#{Rails.root}/db/dummydata/easyshipping/ez_seeder_local_charges.xlsx")
  # req = { 'xlsx' => local_charges }
  # ExcelTool::OverwriteLocalCharges.new(params: req,
  #   user: shipper).perform
  # # byebug

  # ex_lc_data = DataInserter::PfcNordic::LocalChargeInserter.new(data: ex_hubs,
  #   _user: shipper,
  #   counterpart_hub_name: 'Copenhagen Port',
  #   hub_type: 'ocean',
  #   direction: 'export'
  # ).perform

  # imp_lc_data = DataInserter::PfcNordic::LocalChargeInserter.new(data: imp_hubs,
  #   _user: shipper,
  #   counterpart_hub_name: 'Copenhagen Port',
  #   hub_type: 'ocean',
  #   direction: 'import'
  # ).perform
end
