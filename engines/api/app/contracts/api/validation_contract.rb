# frozen_string_literal: true

module Api
  class ValidationContract < Dry::Validation::Contract
    VALID_PARAM_LOAD_TYPES = %w[cargo_item container].freeze
    VALID_PARAM_TYPES = %w[cargo_item routing].freeze

    ValidationCargoItemSchema = Dry::Schema.Params do
      required(:cargoClass).filled(:string)
      optional(:stackable).value(:bool)
      optional(:dangerous).value(:bool)
      optional(:colliType).maybe(:string)
      optional(:quantity).value(:integer, gteq?: 0)
      optional(:width).maybe(:decimal, gteq?: 0)
      optional(:height).maybe(:decimal, gteq?: 0)
      optional(:length).maybe(:decimal, gteq?: 0)
      optional(:volume).maybe(:decimal, gteq?: 0)
      optional(:weight).value(:decimal, gteq?: 0)
      required(:id).value(:string)
    end

    params do
      optional(:originId).value(:string)
      optional(:destinationId).value(:string)
      optional(:loadType).value(:string)
      optional(:items).array(ValidationCargoItemSchema)
      required(:types).array(:string)
    end

    rule(:items) do
      key.failure("must be present") if values[:items].blank?
    end

    rule(:types) do
      types = values[:types]
      key.failure("must be present") if types.blank?
      key.failure("must be one of #{VALID_PARAM_TYPES.join(' | ')}") unless types.all? { |typ| VALID_PARAM_TYPES.include?(typ) }
    end

    rule(:loadType) do
      key.failure("must be one of #{VALID_PARAM_LOAD_TYPES.join(' | ')}") if VALID_PARAM_LOAD_TYPES.exclude?(values[:loadType])
    end
  end
end
