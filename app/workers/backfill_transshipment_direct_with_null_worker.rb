# frozen_string_literal: true

class BackfillTransshipmentDirectWithNullWorker
  include Sidekiq::Worker

  UNSUPPORTED_TYPES = %w[direct direkt].freeze
  MODELS_WHICH_NEEDS_UPDATE = [
    Pricings::Pricing,
    Journey::RouteSection
  ].freeze

  FailedTransshipmentBackFill = Class.new(StandardError)

  # rubocop:disable Rails/SkipsModelValidations
  def perform
    MODELS_WHICH_NEEDS_UPDATE.each do |models|
      ActiveRecord::Base.transaction do
        models.where("LOWER(transshipment) IN (?)", UNSUPPORTED_TYPES).update_all(transshipment: nil)
        raise FailedTransshipmentBackFill if unsupported_type_exist?(model: models)
      end
    end
  end

  # rubocop:enable Rails/SkipsModelValidations

  private

  def unsupported_type_exist?(model:)
    return true if model.where("LOWER(transshipment) IN (?)", UNSUPPORTED_TYPES).count.positive?

    false
  end
end
