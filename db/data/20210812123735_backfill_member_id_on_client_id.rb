# frozen_string_literal: true

class BackfillMemberIdOnClientId < ActiveRecord::Migration[5.2]
  def up
    BackfillMemberIdOnClientIdWorker.perform_async
  end
end
