# frozen_string_literal: true

module Api
  module V2
    class LineItemDecorator < Draper::Decorator
      decorates "Journey::LineItem"

      delegate_all
      delegate :mode_of_transport, :from, :to, to: :route_section

      def original_value
        nil
      end

      def value
        total
      end

      def section
        return carriage_section if mode_of_transport == "carriage"
        return transfer_section if route_section.from == route_section.to

        freight_charge_category.name
      end

      private

      def carriage_section
        return pre_carriage_charge_category.name if order == 0

        on_carriage_charge_category.name
      end

      def transfer_section
        return export_charge_category.name if order < 2 # wont work need something better

        import_charge_category.name
      end

      def pre_carriage_charge_category
        @pre_carriage_charge_category ||= Legacy::ChargeCategory.find_by(code: "trucking_pre", organization: organization)
      end

      def on_carriage_charge_category
        @on_carriage_charge_category ||= Legacy::ChargeCategory.find_by(code: "trucking_on", organization: organization)
      end

      def freight_charge_category
        @freight_charge_category ||= Legacy::ChargeCategory.find_by(code: "cargo", organization: organization)
      end

      def export_charge_category
        @export_charge_category ||= Legacy::ChargeCategory.find_by(code: "export", organization: organization)
      end

      def import_charge_category
        @import_charge_category ||= Legacy::ChargeCategory.find_by(code: "import", organization: organization)
      end

      def organization
        Organizations::Organization.find(Organizations.current_id)
      end
    end
  end
end
