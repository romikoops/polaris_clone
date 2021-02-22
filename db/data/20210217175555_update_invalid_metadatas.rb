# frozen_string_literal: true
class UpdateInvalidMetadatas < ActiveRecord::Migration[5.2]
  def up
    UpdateInvalidMetadatasWorker.perform_async
  end
end
