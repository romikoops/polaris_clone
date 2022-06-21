# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class Builder
        MissingArgument = Class.new(StandardError)
        TRUCKING_QUERY_DAYS = 10
        DATE_KEYS = %w[effective_date expiration_date].freeze
        MARGIN_KEYS = DATE_KEYS + %w[code cargo_class].freeze
        CONTEXT_KEYS = DATE_KEYS + %w[code context_id].freeze

        def initialize(relation:, request:, period:)
          @request = request
          @period = period
          @relation = relation
        end

        def perform
          return [] if relation.empty?

          charges.compact
        end

        private

        attr_reader :relation, :period, :request

        delegate :scope, :organization, to: :request

        def charges
          @charges ||= all_contexts.flat_map do |context|
            fee_rows_for_context = fees_expanded_by_validities.filter(context)

            OfferCalculator::Service::Charges::ChargesForCargo.new(
              request: request,
              fee_rows: fee_rows_for_context,
              margins: margins_for(context: context, fee_row: fee_rows_for_context.first_row)
            ).perform
          end
        end

        def fees_expanded_by_validities
          @fees_expanded_by_validities ||= date_expander.expand(input: query_frame)
        end

        def margins_expanded_by_validities
          @margins_expanded_by_validities ||= date_expander.expand(input: margin_frame)
        end

        def date_expander
          @date_expander ||= OfferCalculator::Service::Charges::DateExpander.new(period: period, dates: all_dates)
        end

        def all_contexts
          OfferCalculator::Service::Charges::Separator.new(fee_frame: fees_expanded_by_validities, margin_frame: margins_expanded_by_validities).perform
        end

        def all_dates
          @all_dates ||= margin_frame[DATE_KEYS].concat(query_frame[DATE_KEYS])
        end

        def applicables
          @applicables ||= OrganizationManager::HierarchyService.new(target: request.client, organization: organization).fetch.reverse
        end

        def margin_frame
          @margin_frame ||= OfferCalculator::Service::Charges::Margins.new(
            applicables: applicables.reverse,
            period: period,
            fee_codes: query_frame[["code"]],
            type: charge_type,
            cargo_classes: request.cargo_classes
          ).perform
        end

        def query_frame
          @query_frame ||= OfferCalculator::Service::Charges::RelationData.new(relation: relation, period: period).frame
        end

        def rate_arguments
          %w[itinerary_id
            tenant_vehicle_id
            cargo_class
            origin_hub_id
            destination_hub_id
            code
            margin_type]
        end

        def charge_type
          relation.klass.name.demodulize
        end

        def margins_for(context:, fee_row:)
          context_related_margins = margins_expanded_by_validities.filter(context.slice(*MARGIN_KEYS))
          context_related_margins["context_id"] = context["context_id"]
          return context_related_margins if fee_row.nil?

          context_related_margins.filter_any(fee_row.slice(*rate_arguments).compact)
        end
      end
    end
  end
end
