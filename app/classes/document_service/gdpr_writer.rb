# frozen_string_literal: true

require 'bigdecimal'

module DocumentService
  class GdprWriter
    include AwsConfig
    include WritingTool
    attr_reader :organization, :user_contacts, :filename, :directory, :workbook, :worksheet, :user,
                :user_shipments, :user_messages, :user_addresses, :user_sheet, :contacts_sheet, :shipment_sheet

    def initialize(options)
      @user = Users::User.find(options[:user_id])
      @organization = Organizations::Organization.find_by(id: user.organization_id)
      @user_contacts = Legacy::Contact.where(user: @user)
      @user_shipments = Legacy::Shipment.where(user: @user).where.not(status: 'booking_process_started')
      @user_addresses = Legacy::UserAddress.where(user: @user)
      @filename = "#{user_profile.first_name}_#{user_profile.last_name}_GDPR.xlsx"
      @directory = "tmp/#{@filename}"
      @workbook = create_workbook(@directory)
      header_format = @workbook.add_format
      header_format.set_bold
      @user_sheet = workbook.add_worksheet('Account')
      @contacts_sheet = workbook.add_worksheet('Contacts')
      @shipment_sheet = workbook.add_worksheet('Shipments')
    end

    def perform
      write_user_data
      write_contacts_data
      write_shipment_data
      workbook.close
      write_to_aws(directory, organization, filename, 'gdpr')
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
         uid)
    end

    def write_user_data
      row = 1
      user_keys.each do |k|
        user_sheet.write(row, 0, k.humanize)
        user_sheet.write(row, 1, (user[k] || user_profile[k]))
        row += 1
      end
    end

    def write_contacts_data
      row = 1
      user_contacts.each do |uc|
        uc.as_json.each do |k, value|
          if k.to_s == 'address_id'
            loc = Legacy::Address.find(value)
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
        tender = shipment.charge_breakdowns.selected.tender

        shipment_sheet.write(row, 0, shipment.origin_hub&.address&.geocoded_address)
        shipment_sheet.write(row, 1, shipment.destination_hub&.address&.geocoded_address)
        shipment_sheet.write(row, 2, shipment.imc_reference)
        shipment_sheet.write(row, 3, shipment.status)
        shipment_sheet.write(row, 4, shipment.load_type.humanize)
        shipment_sheet.write(row, 5, shipment.has_pre_carriage ? 'Yes' : 'No')
        shipment_sheet.write(row, 6, shipment.has_on_carriage ? 'Yes' : 'No')
        shipment_sheet.write(row, 7, shipment.planned_etd)
        shipment_sheet.write(row, 8, shipment.planned_eta)
        shipment_sheet.write(
          row,
          9,
          section_total(tender: tender)
        )
        shipment_sheet.write(
          row,
          10,
          section_total(tender: tender, section: 'customs_section')
        )
        shipment_sheet.write(
          row,
          11,
          section_total(tender: tender, section: 'insurance_section')
        )
        row += 1
      end
    end

    def user_profile
      @user_profile ||= Profiles::Profile.find_by(user_id: user.id)
    end

    def section_total(tender:, section: nil)
      return 'N/A' unless tender.present? && (section.present? && tender.line_items.exists?(section: section))
      return tender.amount.format if section.blank?

      tender.line_items.where(section: section).sum(Money.new(0, tender.amount_currency), &:amount).format
    end
  end
end
