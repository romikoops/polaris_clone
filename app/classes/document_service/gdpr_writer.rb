# frozen_string_literal: true

require 'bigdecimal'

module DocumentService
  class GdprWriter
    include AwsConfig
    include WritingTool
    attr_reader :tenant, :user_contacts, :filename, :directory, :workbook, :worksheet, :user, :user_aliases,
                :user_shipments, :user_messages, :user_addresses, :user_sheet, :alias_sheet, :contacts_sheet, :shipment_sheet

    def initialize(options)
      @user = User.find(options[:user_id])
      @user_contacts = @user.contacts.where(alias: false)
      @user_aliases = @user.contacts.where(alias: true)
      @user_shipments = @user.shipments
      @user_messages = @user.conversations
      @user_addresses = @user.user_addresses
      @filename = "#{@user.first_name}_#{@user.last_name}_GDPR.xlsx"
      @directory = "tmp/#{@filename}"
      @workbook = create_workbook(@directory)
      header_format = @workbook.add_format
      header_format.set_bold
      @user_sheet = workbook.add_worksheet('Account')
      @alias_sheet = workbook.add_worksheet('Aliases')
      @contacts_sheet = workbook.add_worksheet('Contacts')
      @shipment_sheet = workbook.add_worksheet('Shipments')
    end

    def perform
      write_user_Data
      write_alias_Data
      write_contacts_Data
      write_shipment_data
      workbook.close
      write_to_aws(directory, user.tenant, filename, 'gdpr')
    end

    private

    def user_keys
      %w(sign_in_count
         last_sign_in_at
         ast_sign_in_ip
         nickname
         email
         company_name
         first_name
         last_name
         phone
         currency
         vat_number
         uid)
    end

    def write_user_Data
      row = 1
      user_keys.each do |k|
        user_sheet.write(row, 0, k.humanize)
        user_sheet.write(row, 1, user[k])
        row += 1
      end
    end

    def write_alias_Data
      row = 1
      user_aliases.each do |ua|
        ua.as_json.each do |k, value|
          if k.to_s == 'address_id'
            loc = Address.find(value)
            loc.set_geocoded_address_from_fields! unless loc.geocoded_address
            alias_sheet.write(row, 0, k.humanize)
            alias_sheet.write(row, 1, loc.geocoded_address)
          else
            alias_sheet.write(row, 0, k.humanize)
            alias_sheet.write(row, 1, value)
          end
          row += 1
        end
        row += 1
      end
    end

    def write_contacts_Data
      row = 1
      user_contacts.each do |uc|
        uc.as_json.each do |k, value|
          if k.to_s == 'address_id'
            loc = Address.find(value)
            loc.set_geocoded_address_from_fields! unless loc.geocoded_address
            contacts_sheet.write(row, 0, k.humanize)
            contacts_sheet.write(row, 1, loc.geocoded_address)
          else
            contacts_sheet.write(row, 0, k.humanize)
            contacts_sheet.write(row, 1, value)
          end
          row += 1
        end
        row += 1
      end
    end

    def shipment_headers
      %w(origin_id
         destination_id
         imc_reference
         status
         load_type
         has_pre_carriage
         has_on_carriage
         planned_eta
         planned_etd
         total_price
         insurance
         customs)
    end

    def write_shipment_headers
      shipment_headers.each_with_index do |header, i|
        shipment_sheet.write(0, i, header.humanize)
      end
    end

    def write_shipment_data
      write_shipment_headers
      row = 1
      user_shipments.each do |shipment|
        next unless shipment.status != 'booking_process_started'
        shipment_sheet.write(row, 0, shipment.origin_hub.address.geocoded_address)
        shipment_sheet.write(row, 1, shipment.destination_hub.address.geocoded_address)
        shipment_sheet.write(row, 2, shipment.imc_reference)
        shipment_sheet.write(row, 3, shipment.status)
        shipment_sheet.write(row, 4, shipment.load_type.humanize)
        shipment_sheet.write(row, 5, shipment.has_pre_carriage ? 'Yes' : 'No')
        shipment_sheet.write(row, 6, shipment.has_on_carriage ? 'Yes' : 'No')
        shipment_sheet.write(row, 7, shipment.planned_etd)
        shipment_sheet.write(row, 8, shipment.planned_eta)
        shipment_sheet.write(row, 9, "#{shipment.total_price[:currency]} #{shipment.total_price[:value].to_d.round(2)}")
        shipment_sheet.write(row, 10, shipment.insurance && shipment.insurance['val'] ? "#{shipment.insurance['currency']} #{shipment.insurance['val'].to_d.round(2)}" : 'N/A')
        shipment_sheet.write(row, 11, shipment.customs && shipment.customs['val'] ? "#{shipment.customs['currency']} #{shipment.customs['val'].to_d.round(2)}" : 'N/A')
        row += 1
      end
    end
  end
end
