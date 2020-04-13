# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class QuotationsController < ApiController
      def create
        if validation.errors.present?
          render json: ValidationErrorSerializer.new(validation.errors), status: 417
        else
          tenders = quotation_service.tenders
          render json: TenderSerializer.new(tenders, params: { scope: current_scope })
        end
      rescue Wheelhouse::ApplicationError => e
        render json: { error: e.message }, status: 422
      end

      def show
        decorated_quotation = QuotationDecorator.decorate(quotation)

        render json: QuotationSerializer.new(decorated_quotation, params: { scope: current_scope })
      end

      def download
        document = Wheelhouse::PdfService.new(tenders: download_params[:tenders]).download
        render json: PdfSerializer.new(document)
      end

      private

      def validation
        validator = Wheelhouse::ValidationService.new(
          user: user,
          cargo: cargo,
          routing: routing,
          load_type: load_type,
          final: true
        )
        validator.validate
        validator
      end

      def quotation
        Quotations::Quotation.find(params[:id])
      end

      def quotation_service
        Wheelhouse::QuotationService.new(quotation_details: quotation_details, shipping_info: shipment_params)
      end

      def quotation_details
        details = quotation_params.to_h
        details[:user_id] = current_user.id if details[:user_id].blank?
        details
      end

      def quotation_params
        params.require(:quote).permit(
          :selected_date,
          :user_id,
          :load_type,
          :delay,
          origin: [*address_params, hub_ids: []],
          destination: [*address_params, hub_ids: []]
        )
      end

      def shipment_params
        cargo_items_attributes = %i[id payload_in_kg dimension_x dimension_y
                                    dimension_z quantity total_weight total_volume
                                    stackable cargo_item_type_id dangerous_goods cargo_class]
        params.require(:shipment_info).permit(cargo_items_attributes: cargo_items_attributes,
                                              containers_attributes: %i[size_class quantity
                                                                        payload_in_kg dangerous_goods cargo_class],
                                              trucking_info: [pre_carriage: [:truck_type], on_carriage: [:truck_type]])
      end

      def address_params
        %i[name zip_code number city country full_address latitude longitude nexus_id nexus_name]
      end

      def download_params
        params.permit(tenders: %i[id])
      end

      def routing
        {
          origin: quotation_params[:origin].to_h,
          destination: quotation_params[:destination].to_h
        }.deep_symbolize_keys
      end

      def load_type
        quotation_params[:load_type]
      end

      def cargo
        units = shipment_params.fetch(:cargo_items_attributes, []).map do |attrs|
          Cargo::Unit.new(
            id: attrs[:id],
            tenant: current_tenant,
            cargo_type: 'LCL',
            cargo_class: '00',
            width_value: attrs[:dimension_x].to_f / 100,
            height_value: attrs[:dimension_z].to_f / 100,
            length_value: attrs[:dimension_y].to_f / 100,
            weight_value: attrs[:payload_in_kg].to_f,
            quantity: attrs[:quantity]
          )
        end
        Cargo::Cargo.new(
          tenant: current_tenant,
          units: units
        )
      end

      def user
        Tenants::User.find_by(id: quotation_params[:user_id]) || current_user
      end
    end
  end
end
