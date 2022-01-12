# frozen_string_literal: true

module Api
  module V2
    class RequestForQuotationsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:create]
      before_action :validate_create_params_presence, only: [:create]

      def create
        request_for_quotation_params = create_params.transform_keys { |key| key.to_s.underscore.to_sym }

        request_for_quotation_params.merge!(query: query, organization_id: Organizations.current_id, company_name: company_name)
        request_for_quotation = Journey::RequestForQuotation.new(request_for_quotation_params)

        ActiveRecord::Base.transaction do
          request_for_quotation.save!
          Rails.configuration.event_store.publish(
            Journey::RequestForQuotationEvent.new(data: {
              query_id: query.to_global_id,
              request_for_quotation_id: request_for_quotation.to_global_id
            }),
            stream_name: "Organization$#{request_for_quotation_params[:organization_id]}"
          )
        end
        render status: :created, json: Api::V2::RequestForQuotationSerializer.new(request_for_quotation)
      end

      private

      def query
        @query ||= Journey::Query.find(params[:query_id])
      end

      def client
        @client ||= query.client
      end

      def company_name
        @company_name ||= begin
          company = Companies::Company.joins(:memberships).find_by(companies_memberships: { client_id: client.id }) if client.present?

          company.name if company.present?
        end
      end

      def create_params
        @create_params ||= params.require(:request_for_quotation).permit(
          :query_id,
          :note,
          :fullName,
          :phone,
          :email
        )
      end

      def validate_create_params_presence
        create_params.require(%i[fullName email phone])
      end
    end
  end
end
