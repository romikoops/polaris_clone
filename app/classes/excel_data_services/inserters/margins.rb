# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Margins < ExcelDataServices::Inserters::Base
      def tenants_tenant
        @tenants_tenant ||= ::Tenants::Tenant.find_by(legacy_id: tenant.id)
      end

      def perform
        data.each do |group_of_row_data|
          row = ExcelDataServices::Rows::Base.get(klass_identifier).new(
            row_data: group_of_row_data.first, tenant: tenant
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
          tenant: tenant,
          name: row.itinerary_name,
          mode_of_transport: row.mot,
          sandbox: @sandbox
        )
      end

      def find_tenant_vehicle(row)
        carrier = Carrier.find_by(name: row.carrier) if row.carrier.present?

        TenantVehicle.find_by(
          tenant: tenant,
          name: row.service_level,
          mode_of_transport: row.mot,
          carrier: carrier,
          sandbox: @sandbox
        )
      end

      def create_margin_with_margin_details(group_of_row_data, row, tenant_vehicle, itinerary) # rubocop:disable Metrics/AbcSize
        margin_applies_to_all_fees = margin_applies_to_all_fees?(group_of_row_data.size, row.fee_code)
        margin_params =
          { tenant: tenants_tenant,
            tenant_vehicle: tenant_vehicle,
            applicable: options[:applicable],
            operator: margin_applies_to_all_fees ? row.operator : nil,
            value: margin_applies_to_all_fees ? row.margin : nil,
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

        margins_for_new_margin_details = act_on_overlapping_margins(margins_with_actions)

        return if margin_applies_to_all_fees

        new_margin_detail_params_arr = build_margin_detail_params_for_margin(group_of_row_data)
        new_margin_detail_params_arr.each do |margin_detail_params|
          margins_for_new_margin_details.each do |margin|
            new_margin_detail = margin.details.new(margin_detail_params)

            add_stats(new_margin_detail)
            new_margin_detail.save!
          end
        end
      end

      def margin_applies_to_all_fees?(group_size, fee_code)
        group_size == 1 && (fee_code.nil? || fee_code.casecmp('all').zero?)
      end

      def act_on_overlapping_margins(margins_with_actions)
        margins_with_actions.slice(:destroy).values.each do |margins|
          margins.each do |margin|
            margin.details.each do |margin_detail|
              margin_detail.destroy
              add_stats(margin_detail)
            end
            margin.destroy
            add_stats(margin)
          end
        end

        new_margins = []
        margins_with_actions.slice(:save).values.each do |margins|
          margins.map do |margin|
            new_margins << margin if margin.new_record? && !margin.transient_marked_as_old
            add_stats(margin)
            margin.save!
          end
        end

        new_margins
      end

      def build_margin_detail_params_for_margin(group_of_row_data)
        group_of_row_data.map do |row_data|
          row = ExcelDataServices::Rows::Base.get(klass_identifier).new(row_data: row_data, tenant: tenant)

          charge_category = ChargeCategory.from_code(
            tenant_id: tenant.id,
            code: row.fee_code,
            sandbox: @sandbox
          )

          { tenant_id: tenants_tenant.id,
            charge_category_id: charge_category.id,
            operator: row.operator,
            sandbox: @sandbox,
            value: row.margin }
        end
      end
    end
  end
end
