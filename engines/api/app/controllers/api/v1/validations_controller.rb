# frozen_string_literal: true

module Api
  module V1
    class ValidationsController < ApiController
      def create
        validator = Wheelhouse::ValidationService.new(
          user: user,
          organization: current_organization,
          cargo: cargo,
          routing: routing,
          load_type: load_type
        )
        validator.validate
        render json: ValidationErrorSerializer.new(validator.errors)
      end

      private

      def user
        Users::User.find_by(id: user_param[:user_id]) || current_user
      end

      def user_param
        params.require(:quote).permit(:user_id)
      end

      def load_type
        params.require(:quote).permit(:load_type)[:load_type]
      end

      def routing_params
        params.require(:quote).permit(
          origin: address_params,
          destination: address_params
        )
      end

      def routing
        {
          origin: routing_params[:origin].to_h,
          destination: routing_params[:destination].to_h
        }.deep_symbolize_keys
      end

      def cargo
        Cargo::Cargo.new(
          organization: current_organization,
          units: load_type == 'container' ? containers : cargo_items
        )
      end

      def cargo_items
        cargo_params[:cargo_items_attributes].map do |attrs|
          Cargo::Unit.new(
            id: attrs[:id],
            cargo_class: '00',
            cargo_type: 'LCL',
            organization: current_organization,
            width_value: attrs[:width].to_f / 100,
            height_value: attrs[:height].to_f / 100,
            length_value: attrs[:length].to_f / 100,
            weight_value: attrs[:payload_in_kg].to_f,
            quantity: attrs[:quantity]
          )
        end
      end

      def containers
        cargo_params[:containers_attributes].map do |attrs|
          Cargo::Unit.new(
            id: attrs[:id],
            cargo_class: Cargo::Creator::CARGO_CLASS_LEGACY_MAPPER[attrs[[:cargo_class]]],
            cargo_type: 'GP',
            organization: current_organization,
            weight_value: attrs[:payload_in_kg].to_f,
            quantity: attrs[:quantity]
          )
        end
      end

      def cargo_params
        cargo_items_attributes = %i[id payload_in_kg width length
                                    height quantity total_weight total_volume
                                    stackable cargo_item_type_id dangerous_goods cargo_class]
        params.require(:shipment_info).permit(cargo_items_attributes: cargo_items_attributes,
                                              containers_attributes: %i[id size_class quantity
                                                                        payload_in_kg dangerous_goods cargo_class])
      end

      def address_params
        %i[name zip_code number city country full_address latitude longitude nexus_id nexus_name]
      end
    end
  end
end
