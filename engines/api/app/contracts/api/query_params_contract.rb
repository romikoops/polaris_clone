# frozen_string_literal: true

module Api
  class QueryParamsContract < Dry::Validation::Contract
    VALID_PARAM_LOAD_TYPES = %w[cargo_item container].freeze

    CargoItemSchema = Dry::Schema.Params do
      required(:cargoClass).filled(:string)
      optional(:stackable).value(:bool)
      optional(:dangerous).value(:bool)
      optional(:colliType).filled(:string)
      optional(:quantity).value(:integer, gt?: 0)
      optional(:width).maybe(:decimal, gt?: 0)
      optional(:height).maybe(:decimal, gt?: 0)
      optional(:length).maybe(:decimal, gt?: 0)
      optional(:volume).maybe(:decimal, gt?: 0)
      required(:weight).value(:decimal, gt?: 0)
      optional(:commodities).array(:hash) do
        required(:description).value(:string)
        required(:hsCode).maybe(:string)
        required(:imoClass).maybe(:string)
      end
    end

    params do
      required(:originId).value(:string)
      required(:destinationId).value(:string)
      required(:loadType).value(:string)
      optional(:parentId).maybe(:string)
      optional(:cargoReadyDate).value(:string)
      required(:items).array(CargoItemSchema)
    end

    rule(:items) do
      key.failure("must be present") if values[:items].blank?
    end

    rule(:cargoReadyDate) do
      key.failure("must be in the future") if values[:cargoReadyDate] && Time.zone.today > Time.zone.parse(values[:cargoReadyDate])
    end

    rule(:loadType) do
      key.failure("must be one of #{VALID_PARAM_LOAD_TYPES.join(' | ')}") if VALID_PARAM_LOAD_TYPES.exclude?(values[:loadType])
    end
  end
end
