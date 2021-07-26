# frozen_string_literal: true

class BackfillRoutingCarriersWorker
  include Sidekiq::Worker

  def perform
    Legacy::Carrier.where.not(code: Routing::Carrier.select(:code)).find_each do |carrier|
      Routing::Carrier.create(code: carrier.code, name: carrier.name)
    end
  end
end
