# frozen_string_literal: true

# Going back and checking that the Backfill did its job properly
class VerifyBackfillsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  # origin/destination strings dont match on the Query model
  RoutingVerificationFailed = Class.new(StandardError)
  # Cargo details do not match on the Cargounit model
  CargoVerificationFailed = Class.new(StandardError)
  # Charge details do not match on the LineItem model
  LineItemVerificationFailed = Class.new(StandardError)

  def perform
    validate_quotations
    send_status_email
  end

  def validate_quotations
    total quotations.count
    quotations.find_each.with_index do |quotation, index|
      at(index + 1)
      validate_quotation(quotation: quotation)
    end
  end

  def validate_quotation(quotation:)
    routing_is_valid(quotation: quotation)
    cargo_units_are_valid(quotation: quotation)
    tenders_are_valid(quotation: quotation)
  end

  def quotations
    @quotations ||= Quotations::Quotation
      .joins(:tenders)
      .where(billing: %w[external internal])
      .where("error_class != 'ActionController::ParameterMissing' OR error_class IS NULL ")
  end

  def failures
    @failures ||= []
  end

  def routing_is_valid(quotation:)
    error = QueryComparator.new(legacy: quotation).perform
    register_error(quotation: quotation, message: error) if error
  end

  def cargo_units_are_valid(quotation:)
    CollectiveCargoUnitComparator.new(legacy: quotation).perform.each { |msg| register_error(quotation: quotation, message: msg) }
  end

  def tenders_are_valid(quotation:)
    quotation.tenders.each { |tender| tender_is_valid(tender: tender) }
  end

  def tender_is_valid(tender:)
    register_error(quotation: quotation, message: "Invalid LineItems") if tender.line_items.where.not(section: nil).reject { |tender_line_item| LineItemComparator.new(legacy: tender_line_item).perform }.present?
  end

  def register_error(quotation:, message:)
    failures << { reason: "Quotation #{quotation.id} failed with message: #{message}" }
  end

  def send_status_email
    has_errors = failures.present?
    result = { "has_errors" => has_errors }
    result.merge("errors" => failures) if has_errors
    UploadMailer
      .with(
        user_id: Users::User.find_by(email: "shopadmin@itsmycargo.com").id,
        organization: Organizations::Organization.find_by(slug: "demo"),
        result: result,
        file: "LegacyQuotationBackfillWorker"
      )
      .complete_email
      .deliver_later
  end

  # class for comparing all cargos together

  class CollectiveCargoUnitComparator
    def initialize(legacy:)
      @legacy = legacy
    end

    delegate :cargo, to: :legacy

    def perform
      return [] if cargo.blank?

      cargo.units.flat_map { |unit| CargoUnitComparator.new(legacy: unit, backfilled: Journey::CargoUnit.find_by(id: unit.id)).perform }.compact
    end

    private

    attr_reader :legacy
  end

  # Class for comparing Cargo::Unit and Journey::CargoUnit models
  class CargoUnitComparator
    def initialize(legacy:, backfilled:)
      @legacy = legacy
      @backfilled = backfilled
    end

    def perform
      return ["Cargo::Unit #{unit_id} was not copied"] if backfilled.blank?

      %w[weight height length width].each do |attribute|
        legacy_value = send("legacy_#{attribute}")
        backfilled_value = send("backfilled_#{attribute}")

        "CargoUnit #{backfilled.id} #{attribute} does not match #{legacy_value.format}..." unless backfilled_value == legacy_value
      end
    end

    private

    attr_reader :legacy, :backfilled

    def legacy_weight
      value = legacy.weight
      value.zero? ? Measured::Weight.new(0.0001, "kg") : value
    end

    delegate :id, to: :backfilled, prefix: true

    delegate :height, to: :legacy, prefix: true

    delegate :width, to: :legacy, prefix: true

    delegate :length, to: :legacy, prefix: true

    delegate :weight, to: :backfilled, prefix: true

    delegate :height, to: :backfilled, prefix: true

    delegate :width, to: :backfilled, prefix: true

    delegate :length, to: :backfilled, prefix: true
  end

  # Class for comparing Quotations::LineItem and Journey::LineItem models
  class LineItemComparator
    def initialize(legacy:)
      @legacy = legacy
      @result = ::ResultFormatter::ResultDecorator.new(Journey::Result.find(legacy.tender_id))
    end

    delegate :pre_carriage_section, :on_carriage_section, :origin_transfer_section, :destination_transfer_section, :main_freight_section, to: :result

    def perform
      return [] if found?

      ["LineItem #{legacy.id} did not copy correctly"]
    end

    private

    attr_reader :legacy, :result

    def route_section
      case legacy.section
      when /trucking_pre/
        pre_carriage_section
      when /trucking_on/
        on_carriage_section
      when /export/
        origin_transfer_section
      when /import/
        destination_transfer_section
      when /cargo/
        main_freight_section
      end
    end

    def found?
      result.line_item_sets.order(:created_at).map.with_index do |line_item_set, line_item_set_index|
        amount = line_item_set_index.zero? ? legacy.original_amount : legacy.amount
        line_item_set.line_items.find_by(
          fee_code: legacy.code,
          route_section: route_section,
          total_cents: amount.cents,
          total_currency: amount.currency.iso_code,
          description: legacy.charge_category.name
        )
      end.all?
    end
  end

  # Class for comparing Quotations::Quotations and Journey::Query models
  class QueryComparator
    def initialize(legacy:)
      @legacy = legacy
      @query = Journey::Query.find_by(created_at: legacy.created_at, organization_id: legacy.organization_id)
    end

    def perform
      return [] if query && origins.include?(query.origin) && destinations.include?(query.destination)

      ["Quotation #{legacy.id} Routing did not copy correctly"]
    end

    private

    attr_reader :legacy, :query

    def tender
      legacy.tenders.first
    end

    def fallbacks
      tender.name.to_s.split("-", 2).map(&:strip)
    end

    def origins
      [legacy.pickup_address&.geocoded_address, legacy.origin_nexus&.name, fallbacks.first]
    end

    def destinations
      [legacy.delivery_address&.geocoded_address, legacy.destination_nexus&.name, fallbacks.last]
    end
  end
end
