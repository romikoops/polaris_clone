# frozen_string_literal: true

class BackfillTransshipmentOnRouteSectionsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    results = Journey::Result.joins(:route_sections)
    result_count = results.count
    total result_count
    results.find_each.with_index do |result, index|
      at(index, "Result #{index + 1}/ #{result_count}")

      decorated_result = ResultFormatter::ResultDecorator.new(result)
      decorated_result.main_freight_section.update!(transshipment: decorated_result.itinerary.transshipment)
    end
  end
end
