# frozen_string_literal: true

module Api
  class ValidationContract < Dry::Validation::Contract
    VALID_PARAM_LOAD_TYPES = %w[cargo_item container].freeze

    ValidationCargoItemSchema = Dry::Schema.Params do
      required(:cargoClass).filled(:string)
      optional(:stackable).value(:bool)
      optional(:dangerous).value(:bool)
      optional(:colliType).maybe(:string)
      optional(:quantity).value(:integer, gt?: 0)
      optional(:width).maybe(:decimal, gt?: 0)
      optional(:height).maybe(:decimal, gt?: 0)
      optional(:length).maybe(:decimal, gt?: 0)
      optional(:volume).maybe(:decimal, gt?: 0)
      optional(:weight).value(:decimal, gt?: 0)
      required(:id).value(:string)
    end

    params do
      optional(:originId).value(:string)
      optional(:destinationId).value(:string)
      optional(:loadType).value(:string)
      optional(:cargoReadyDate).value(:string)
      optional(:items).array(ValidationCargoItemSchema)
    end

    rule(:items) do
      key.failure("must be present") if values[:items].blank?
    end

    rule(:loadType) do
      key.failure("must be one of #{VALID_PARAM_LOAD_TYPES.join(' | ')}") if VALID_PARAM_LOAD_TYPES.exclude?(values[:loadType])
    end
  end
end
