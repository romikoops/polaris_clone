# frozen_string_literal: true
class UpdateInvalidMetadatasWorker
  include Sidekiq::Worker

  def perform(*args)
    ActiveRecord::Base.connection.execute("
     UPDATE local_charges
     SET metadata = '{}'::jsonb
     WHERE metadata IS NULL
    ")
    ActiveRecord::Base.connection.execute("
     UPDATE pricings_fees
     SET metadata = '{}'::jsonb
     WHERE metadata IS NULL
    ")
    ActiveRecord::Base.connection.execute("
      UPDATE trucking_truckings
      SET metadata = '{}'::jsonb
      WHERE metadata IS NULL
     ")
  end
end
