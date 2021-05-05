# frozen_string_literal: true

class BackfillRelayEnum < ActiveRecord::Migration[5.2]
  def up
    BackfillRelayEnumWorker.perform_async
  end
end
