# frozen_string_literal: true

module OfferCalculator
  class Calculator
    attr_reader :shipment, :quotation

    def initialize(shipment:, params:, user:, creator:, wheelhouse: false)
      @user           = user
      @shipment       = shipment
      @creator = creator
      @params = params
      @delay = params['delay']
      @isQuote = params['shipment'].delete('isQuote')
      @organization = @shipment.organization
      @quotation = create_quotations_quotations
      @async = params[:async] || false
      @wheelhouse = wheelhouse
    end

    def perform
      update_shipment
      if async.present?
        async_calculation
      else
        results_service.perform
      end
      results_service
    rescue => e
      @quotation.update(error_class: e.class.to_s)
      raise e unless async
    end

    private

    attr_reader :wheelhouse, :organization, :params, :async, :user, :creator

    def results_service
      @results_service ||= OfferCalculator::Results.new(
        shipment: shipment,
        quotation: quotation,
        user: user,
        wheelhouse: wheelhouse,
        async: async,
        mailer: mailer
      )
    end

    def async_calculation
      OfferCalculator::AsyncCalculationJob.perform_later(
        shipment_id: shipment.id,
        quotation_id: quotation.id,
        user_id: user&.id,
        wheelhouse: wheelhouse
      )
      results_service
    end

    def mailer
      'QuoteMailer' unless wheelhouse
    end

    def create_quotations_quotations
      Quotations::Quotation.new(organization: organization,
                                user: user,
                                creator: creator,
                                completed: false,
                                legacy_shipment_id: shipment.id)
    end

    def shipment_update_handler
      @shipment_update_handler ||= OfferCalculator::Service::ShipmentUpdateHandler.new(shipment: shipment,
                                                                                       params: params,
                                                                                       quotation: quotation,
                                                                                       wheelhouse: wheelhouse)
    end

    def update_shipment
      shipment_update_handler.update_nexuses
      shipment_update_handler.update_trucking
      shipment_update_handler.update_incoterm
      shipment_update_handler.update_selected_day
      shipment_update_handler.update_cargo_units
      shipment_update_handler.destroy_previous_charge_breakdowns
      shipment_update_handler.update_billing
      raise OfferCalculator::Errors::InvalidShipmentError unless @shipment.save
      @quotation.legacy_shipment_id = @shipment.id
      raise OfferCalculator::Errors::InvalidQuotationError unless @quotation.save
    end
  end
end
