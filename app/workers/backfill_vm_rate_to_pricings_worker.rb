# frozen_string_literal: true

class BackfillVmRateToPricingsWorker
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection.execute("
      UPDATE pricings_pricings
      SET vm_rate = 1.0
    ")
  end
end
