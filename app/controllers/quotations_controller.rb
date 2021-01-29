# frozen_string_literal: true

class QuotationsController < ApplicationController
  include Wheelhouse::ErrorHandler

  def show
    check_for_errors
    response_handler(
      Api::V1::LegacyQueryDecorator.new(
        query,
        context: {scope: current_scope}
      ).legacy_json
    )
  rescue OfferCalculator::Errors::Failure => e
    handle_error(error: e)
  end

  def download_pdf
    document = Wheelhouse::OfferBuilder.offer(results: Journey::Result.where(id: params[:id]))
    response = if document&.file
      Rails.application.routes.url_helpers.rails_blob_url(document&.file, disposition: "attachment")
    end
    response_handler(key: "quote", url: response)
  end

  def query
    @query ||= Journey::Query.find(params[:id] || params[:quotation_id])
  end

  def check_for_errors
    return if result_set_errors.empty?
    return if latest_result_set.results.present?

    raise OfferCalculator::Errors.from_code(code: result_set_errors.first.code)
  end

  def result_set_errors
    @result_set_errors ||= Journey::Error.where(result_set: latest_result_set)
  end

  def latest_result_set
    @latest_result_set ||= query.result_sets.order(:created_at).last
  end
end
