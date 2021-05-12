# frozen_string_literal: true

module ResultFormatter
  class QueryDecorator < ApplicationDecorator
    delegate_all

    def pickup_address
      Legacy::Address.new(
        latitude: origin_coordinates.y,
        longitude: origin_coordinates.x
      ).reverse_geocode
    end

    def delivery_address
      Legacy::Address.new(
        latitude: destination_coordinates.y,
        longitude: destination_coordinates.x
      ).reverse_geocode
    end

    def pre_carriage?
      Journey::RouteSection.exists?(
        result: results,
        mode_of_transport: :carriage,
        order: 0
      )
    end

    def planned_delivery_date
      delivery_date
    end

    def planned_pickup_date
      cargo_ready_date
    end

    def on_carriage?
      Journey::RouteSection.where.not(order: 0).exists?(result: results, mode_of_transport: :carriage)
    end

    def remarks
      @remarks ||= Legacy::Remark.where(organization: organization).order(order: :asc)
    end

    def scope_notes
      @scope_notes ||= scope["quote_notes"] || []
    end

    def content
      @content ||= Legacy::Content.get_component("QuotePdf", organization_id)
    end

    def user_profile
      @user_profile ||= client.profile || Users::ClientProfile.new
    end

    def references
      @references ||= results.map(&:imc_reference)
    end

    delegate :external_id, :full_name, to: :user_profile
    alias client_name full_name

    def company
      Companies::Company.joins(:memberships)
        .find_by(organization: organization,
                 companies_memberships: {
                   member_id: client_id,
                   member_type: "Users::User"
                 })
    end

    def note_remarks
      @note_remarks ||= results.reduce(Legacy::Note.none) do |notes, result|
        notes.or(Notes::Service.new(itinerary: result.itinerary,
                                    tenant_vehicle: result.legacy_service,
                                    remarks: true).fetch)
      end.uniq.pluck(:body)
    end

    def results
      @results ||= result_sets.order(created_at: :desc).first.results.map do |result|
        ResultFormatter::ResultDecorator.new(result, context: context)
      end
    end

    def total_weight
      @total_weight ||= cargo_units.inject(Measured::Weight.new(0, "kg")) do |memo, unit|
        memo + unit.total_weight
      end
    end

    def total_volume
      @total_volume ||= cargo_units.inject(Measured::Volume.new(0, "m3")) do |memo, unit|
        memo + unit.total_volume
      end
    end

    def modes_of_transport
      results.map(&:mode_of_transport).uniq
    end

    def currency
      return scope[:default_currency] if client_id.nil?

      client.settings.currency
    end
  end
end
