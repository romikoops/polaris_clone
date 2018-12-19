# frozen_string_literal: true

module ExcelRakeHelpers
  require 'fileutils'

  def self.generate_pricing_sheet(tenant, tenant_name, mot, load_type)
    puts "#{tenant_name.titleize}: Writing Pricing - #{mot.capitalize} #{load_type.upcase}..."
    klass = ExcelDataServices::FileWriter.const_get("#{mot.capitalize}#{load_type&.capitalize}")
    file_name = "#{tenant_name}__pricing_#{mot}_#{load_type}"

    document = klass.new(tenant: tenant, file_name: file_name).perform
    path_to_file = Pathname(ActiveStorage::Blob.service.send(:path_for, document.file.key))
    FileUtils.cp path_to_file, Pathname("./#{document.text}")
  end

  def self.generate_local_charges_sheet(tenant, tenant_name, mot = nil)
    if mot.nil?
      puts "#{tenant_name.titleize}: Writing Local Charges - all modes of transport..."
    else
      puts "#{tenant_name.titleize}: Writing Local Charges - #{mot.capitalize}..."
    end

    klass = ExcelDataServices::FileWriter::LocalCharges
    file_name = if mot.nil?
                  "#{tenant_name}__local_charges"
                else
                  "#{tenant_name}__local_charges_#{mot}"
                end

    document = klass.new(tenant: tenant, file_name: file_name, mode_of_transport: mot).perform
    path_to_file = Pathname(ActiveStorage::Blob.service.send(:path_for, document.file.key))
    FileUtils.cp path_to_file, Pathname("./#{document.text}")
  end
end

namespace :excel do
  desc 'Download (currently) Ocean & Air pricings for each tenant.'
  task download_all_tenant_ocean_air_pricings_and_local_charges: :environment do
    # Create container directory in tmp
    dir = Rails.root.join('tmp', 'tenant_pricings')
    Dir.mkdir(dir) unless Dir.exist?(dir)
    Dir.chdir(dir)

    tenants = Tenant.all
    # tenants = [Tenant.saco]

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
end
