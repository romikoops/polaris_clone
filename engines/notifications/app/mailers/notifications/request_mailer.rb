# frozen_string_literal: true

module Notifications
  class RequestMailer < AdminMailer
    def request_created
      @request_for_quotation = params[:request_for_quotation]
      @cargo_units = query.cargo_units.map { |cargo| Notifications::CargoUnitDecorator.new(cargo) }
      mail to: params[:recipient],
           from: @request_for_quotation.email,
           reply_to: @request_for_quotation.email,
           subject: subject_line
    end

    def subject_line
      "ItsMyCargo RFQ: #{query.load_type.to_s.upcase} / #{query.origin} -> #{query.destination} / #{@request_for_quotation.email}"
    end

    def query
      @query ||= params[:query]
    end
  end
end
