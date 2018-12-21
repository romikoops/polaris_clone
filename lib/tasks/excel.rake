# frozen_string_literal: true

module ExcelRakeHelpers
  require 'fileutils'

  def self.generate_pricing_sheet(tenant, tenant_name, mot, load_type)
    puts "#{tenant_name.titleize}: Writing Pricing - #{mot.capitalize} #{load_type.upcase}..."
    klass = ExcelDataServices::FileWriter.const_get("#{mot.capitalize}#{load_type&.capitalize}")
    file_name = "#{tenant_name}__pricing_#{mot}_#{load_type}.xlsx"

    document = klass.new(tenant: tenant, file_name: file_name).perform
    path_to_file = Pathname(ActiveStorage::Blob.service.send(:path_for, document.file.key))
    FileUtils.cp path_to_file, Pathname("./#{document.text}")
  end

  def self.generate_local_charges_sheet(tenant, tenant_name, mot = nil)
    if mot.nil?
      puts "#{tenant_name.titleize}: Writing Local Charges - all modes of transport..."
      file_name = "#{tenant_name}__local_charges"
    else
      puts "#{tenant_name.titleize}: Writing Local Charges - #{mot.capitalize}..."
      file_name = "#{tenant_name}__local_charges_#{mot}"
    end

    klass = ExcelDataServices::FileWriter::LocalCharges

    document = klass.new(tenant: tenant, file_name: file_name, mode_of_transport: mot).perform
    path_to_file = Pathname(ActiveStorage::Blob.service.send(:path_for, document.file.key))
    FileUtils.cp path_to_file, Pathname("./#{document.text}")
  end

  def self.upload_pricing_sheet(tenant, tenant_name, mot, load_type)
    puts "#{tenant_name.titleize}: Uploading Pricing - #{mot.capitalize} #{load_type.upcase}..."
    file_name = "#{tenant_name}__pricing_#{mot}_#{load_type}.xlsx"
    klass_identifier = "#{mot.capitalize}#{load_type.capitalize}"

    klass = ExcelDataServices::FileParser.const_get(klass_identifier)
    options = { tenant: tenant, file_or_path: file_name }
    sheets_data = klass.new(options).perform

    klass = ExcelDataServices::DatabaseInserter.const_get(klass_identifier)
    options = { tenant: tenant,
                data: sheets_data,
                options: { should_generate_trips: false } }
    insertion_stats = klass.new(options).perform

    awesome_print insertion_stats
  end

  def self.upload_local_charges_sheet(tenant, tenant_name, mot = nil)
  end
end

namespace :excel do
  desc 'Download (currently) Ocean & Air pricings for each tenant (locally).'
  task download_all_tenant_ocean_air_pricings_and_local_charges: :environment do
    # Create container directory in tmp
    dir = Rails.root.join('tmp', 'tenant_pricings')
    Dir.mkdir(dir) unless Dir.exist?(dir)
    Dir.chdir(dir)

    tenants = Tenant.where.not('subdomain LIKE ?', '%sandbox')
    # tenants = Tenant.all
    # tenants = [Tenant.greencarrier]

    tenants.each do |tenant|
      # Create container directory for each tenant
      tenant_name = tenant.subdomain.downcase
      tenant_dir = File.join(dir, tenant_name)
      Dir.mkdir(tenant_dir) unless Dir.exist?(tenant_dir)
      Dir.chdir(tenant_dir)

      # Write Excel Sheets
      ## Pricings
      ExcelRakeHelpers.generate_pricing_sheet(tenant, tenant_name, 'ocean', 'fcl')
      ExcelRakeHelpers.generate_pricing_sheet(tenant, tenant_name, 'ocean', 'lcl')
      ExcelRakeHelpers.generate_pricing_sheet(tenant, tenant_name, 'air', 'lcl')

      ## Local Charges
      ExcelRakeHelpers.generate_local_charges_sheet(tenant, tenant_name, nil)
    end
  end

  desc 'Upload (currently) Ocean & Air pricings for each tenant (locally).'
  task upload_all_tenant_ocean_air_pricings_and_local_charges: :environment do
    # Create container directory in tmp
    dir = Rails.root.join('tmp', 'tenant_pricings')
    Dir.chdir(dir)

    tenants = Tenant.where.not('subdomain LIKE ?', '%sandbox')
    # tenants = Tenant.all
    # tenants = [Tenant.saco]

    tenants.each do |tenant|
      # Create container directory for each tenant
      tenant_name = tenant.subdomain.downcase
      tenant_dir = File.join(dir, tenant_name)
      Dir.chdir(tenant_dir)

      # Upload Excel Sheets
      ## Pricings
      ExcelRakeHelpers.upload_pricing_sheet(tenant, tenant_name, 'ocean', 'fcl')
      ExcelRakeHelpers.upload_pricing_sheet(tenant, tenant_name, 'ocean', 'lcl')
      ExcelRakeHelpers.upload_pricing_sheet(tenant, tenant_name, 'air', 'lcl')

      ## Local Charges
      ExcelRakeHelpers.upload_pricing_sheet(tenant, tenant_name, 'air', 'lcl')
    end
  end
end
