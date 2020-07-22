# frozen_string_literal: true

module OfferCalculator
  module Service
    class ShipmentUpdateHandler < Base # rubocop:disable Metrics/ClassLength
      InvalidPickupAddress = Class.new(StandardError)
      InvalidDeliveryAddress = Class.new(StandardError)

      def initialize(shipment:, params:, quotation:, wheelhouse: false)
        @params = params
        @quotation = quotation
        super(shipment: shipment, quotation: quotation)
      end

      def clear_previous_itinerary
        return if @shipment.itinerary.nil?

        @shipment.itinerary = nil
        @shipment.trip      = nil
        @shipment.save
      end

      def update_nexuses
        @shipment.origin_nexus_id      = @params[:shipment][:origin][:nexus_id]
        @shipment.destination_nexus_id = @params[:shipment][:destination][:nexus_id]
        @quotation.origin_nexus_id      = @params[:shipment][:origin][:nexus_id]
        @quotation.destination_nexus_id = @params[:shipment][:destination][:nexus_id]
      end

      def update_trucking
        # Setting trucking also sets has_on_carriage and has_pre_carriage
        @shipment.update(trucking: trucking_params.to_h)
        { origin: 'pre', destination: 'on' }.each do |target, carriage|
          next unless trucking_requested(target: target)

          address = Legacy::Address.new_from_raw_params(address_params(target))
          raise_trucking_address_error(target) if trucking_address_invalid?(address)
          address.save!
          @shipment.trucking["#{carriage}_carriage"]['address_id'] = address.id
          if carriage == 'pre'
            @quotation.pickup_address_id = address.id
          else
            @quotation.delivery_address_id = address.id
          end
        end
      end

      def trucking_requested(target:)
        @params[:shipment][target][:nexus_id].blank?
      end

      def update_updated_at
        @shipment.touch
      end

      def update_billing
        email = @shipment.user&.email || ''
        return @shipment.billing = :test if email.include?('itsmycargo.com')
        internal_domain = scope.fetch(:internal_domains).find { |domain|  email.include?(domain) }
        return @shipment.billing = :internal if internal_domain.present? || wheelhouse

        @shipment.billing = :external
      end

      def update_cargo_units
        destroy_previous_cargo_units

        if aggregated_cargo_shipment?
          @shipment.aggregated_cargo = Legacy::AggregatedCargo.new(aggregated_cargo_params)
          @shipment.aggregated_cargo.set_chargeable_weight!
        else
          @shipment.cargo_units = cargo_unit_const.extract(cargo_units_params)
        end
        Cargo::Creator.new(legacy_shipment: @shipment, quotation: @quotation).perform if @quotation.save
      rescue ActiveRecord::RecordNotSaved
        raise OfferCalculator::Errors::InvalidCargoUnit
      end

      def update_incoterm
        @shipment.incoterm_id = @params[:shipment][:incoterm]
      end

      def update_selected_day
        date = Chronic.parse(@params[:shipment][:selected_day], endian_precedence: :little)
        date_limit = Time.zone.today
        @shipment.desired_start_date = [date, date_limit].max
        @quotation.selected_date = @shipment.desired_start_date
      end

      def destroy_previous_charge_breakdowns
        @shipment.charge_breakdowns.destroy_all
      end

      def set_trucking_nexuses(hubs:)
        %w[origin destination].each do |target|
          next if @shipment.send("#{target}_nexus_id").present?

          nexus_ids = hubs[target.to_sym].pluck(:nexus_id).uniq

          @shipment.update("#{target}_nexus_id" => nexus_ids.first) if nexus_ids.length == 1
        end
      end

      private

      def cargo_unit_const
        "Legacy::#{@shipment.load_type.camelize}".constantize
      end

      def plural_load_type
        @shipment.load_type.pluralize
      end

      def cargo_items_params
        @params.require(:shipment).permit(
          cargo_items_attributes: %i(
            payload_in_kg width length height
            quantity cargo_item_type_id dangerous_goods stackable
            contents
          )
        )[:cargo_items_attributes]
      end

      def containers_params
        @params.require(:shipment).permit(
          containers_attributes: %i(
            payload_in_kg size_class tareWeight quantity dangerous_goods contents
          )
        )[:containers_attributes].map do |container_attributes|
          container_attributes.to_h.deep_transform_keys { |k| k.to_s.underscore }
        end
      end

      def aggregated_cargo_shipment?
        @params[:shipment][:aggregated_cargo_attributes]
      end

      def aggregated_cargo_params
        @params.require(:shipment).require(:aggregated_cargo_attributes).permit(:weight, :volume)
      end

      def cargo_units_params
        send("#{plural_load_type}_params")
      end

      def destroy_previous_cargo_units
        @shipment.aggregated_cargo.try(:destroy)
        @shipment.aggregated_cargo = nil
        @shipment.cargo_items.destroy_all
        @shipment.containers.destroy_all
      end

      def trucking_address_invalid?(address)
        !address.valid?
      end

      def address_params(target)
        unsafe_address_hash = @params.require(:shipment).require(target).to_unsafe_hash
        snakefied_address_hash = unsafe_address_hash.deep_transform_keys { |k| k.to_s.underscore }
        snakefied_address_hash.deep_symbolize_keys!
        snakefied_address_hash[:geocoded_address] = snakefied_address_hash.delete(:full_address)
        snakefied_address_hash[:street_number] = snakefied_address_hash.delete(:number)
        ActionController::Parameters.new(snakefied_address_hash)
      end

      def raise_trucking_address_error(target)
        raise OfferCalculator::Errors::InvalidPickupAddress   if target == :origin
        raise OfferCalculator::Errors::InvalidDeliveryAddress if target == :destination
      end

      def trucking_params
        @params.require(:shipment).require(:trucking).permit(
          on_carriage: :truck_type, pre_carriage: :truck_type
        )
      end
    end
  end
end
