# frozen_string_literal: true
class SubscribeOrgsToOfferCreated < ActiveRecord::Migration[5.2]
  def up
    SubscribeOrgsToOfferCreatedWorker.perform_async
  end
end
