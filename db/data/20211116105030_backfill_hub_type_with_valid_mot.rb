# frozen_string_literal: true

class BackfillHubTypeWithValidMot < ActiveRecord::Migration[5.2]
  def up
    BackfillHubTypeWithValidMotWorker.perform_async
  end
end
