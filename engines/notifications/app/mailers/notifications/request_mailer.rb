# frozen_string_literal: true
module Notifications
  class RequestMailer < AdminMailer
    def request_created
      @query = params[:query]
      @mode_of_transport = params[:mode_of_transport]
      @note = params[:note]
      @client = @query.client
      @cargo_units = @query.cargo_units.map { |cargo| Notifications::CargoUnitDecorator.new(cargo) }

      mail to: params[:recipient],
           from: @query.client.email,
           reply_to: @query.client.email,
           subject: subject_line
    end

    def subject_line
      "ItsMyCargo RFQ: #{@mode_of_transport.upcase} / #{@query.load_type.to_s.upcase} / #{@query.origin} -> #{@query.destination} / #{@client.email}"
    end
  end
end
