# frozen_string_literal: true

class BackfillQueryIdToErrors < ActiveRecord::Migration[5.2]
  def up
    BackfillQueryIdToErrorsWorker.perform_async
  end
end
