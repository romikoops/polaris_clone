# frozen_string_literal: true

class CorrectRelayBackfillSnafu < ActiveRecord::Migration[5.2]
  def up
    CorrectRelayBackfillSnafuWorker.perform_async
  end
end
