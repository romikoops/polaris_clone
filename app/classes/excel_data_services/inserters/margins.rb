# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Margins < ExcelDataServices::Inserters::Base
      def perform
        data.each do |group_of_row_data|
          row = ExcelDataServices::Rows::Base.get(klass_identifier).new(
            row_data: group_of_row_data.first, organization: organization
          )

          itinerary = find_itinerary(row)
          tenant_vehicle = find_tenant_vehicle(row)

          create_margin_with_margin_details(group_of_row_data, row, tenant_vehicle, itinerary)
        end

        stats
      end

      private

      def find_itinerary(row)
        Itinerary.find_by(
          organization: organization,
          name: row.itinerary_name,
          mode_of_transport: row.mot,
          sandbox: @sandbox
        )
      end

      def find_tenant_vehicle(row)
        carrier = carrier_from_code(name: row.carrier) if row.carrier.present?

        TenantVehicle.find_by(
          organization: organization,
          name: row.service_level,
          mode_of_transport: row.mot,
          carrier: carrier,
          sandbox: @sandbox
        )
      end

      def create_margin_with_margin_details(group_of_row_data, row, tenant_vehicle, itinerary) # rubocop:disable Metrics/AbcSize
        margin_applies_to_all_fees = margin_applies_to_all_fees?(group_of_row_data.size, row.fee_code)
        margin_params =
          { organization: organization,
            tenant_vehicle: tenant_vehicle,
            applicable: options[:applicable],
            operator: margin_applies_to_all_fees ? row.operator : '%',
            value: margin_applies_to_all_fees ? row.margin : 0,
            cargo_class: row.load_type,
            itinerary_id: itinerary.id,
            sandbox: @sandbox,
            margin_type: row.margin_type,
            effective_date: Date.parse(row.effective_date.to_s).beginning_of_day,
            expiration_date: Date.parse(row.expiration_date.to_s).end_of_day.change(usec: 0) }

        old_margins = Pricings::Margin.where(margin_params.except(:effective_date, :expiration_date))
        new_margin = Pricings::Margin.new(margin_params)
        overlap_handler = ExcelDataServices::Inserters::DateOverlapHandler.new(old_margins, new_margin)
        margins_with_actions = overlap_handler.perform

        margins_for_new_margin_details = act_on_overlapping_margins(margins_with_actions, row[:row_nr])

        return if margin_applies_to_all_fees

        new_margin_detail_params_arr = build_margin_detail_params_for_margin(group_of_row_data)
        new_margin_detail_params_arr.each do |margin_detail_params|
          margins_for_new_margin_details.each do |margin|
            new_margin_detail = margin.details.new(margin_detail_params)

            add_stats(new_margin_detail, row[:row_nr])
            new_margin_detail.save!
          end
        end
      end

      def margin_applies_to_all_fees?(group_size, fee_code)
        group_size == 1 && (fee_code.nil? || fee_code.casecmp('all').zero?)
      end

      def act_on_overlapping_margins(margins_with_actions, row_nr)
        margins_with_actions.slice(:destroy).values.each do |margins|
          margins.each do |margin|
            margin.details.each do |margin_detail|
              margin_detail.destroy
              add_stats(margin_detail, row_nr)
            end
            margin.destroy
            add_stats(margin, row_nr)
          end
        end

        new_margins = []
        margins_with_actions.slice(:save).values.each do |margins|
          margins.map do |margin|
            new_margins << margin if margin.new_record? && !margin.transient_marked_as_old
            add_stats(margin, row_nr)
            margin.save!
          end
        end

        new_margins
      end

      def build_margin_detail_params_for_margin(group_of_row_data)
        group_of_row_data.map do |row_data|
          row = ExcelDataServices::Rows::Base.get(klass_identifier).new(row_data: row_data, organization: organization)

          charge_category = ChargeCategory.from_code(
            organization_id: organization.id,
            code: row.fee_code,
            sandbox: @sandbox
          )

          { organization_id: organization.id,
            charge_category_id: charge_category.id,
            operator: row.operator,
            sandbox: @sandbox,
            value: row.margin }
        end
      end
    end
  end
end
