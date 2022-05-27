# frozen_string_literal: true

class BackfillUploaderScopes < ActiveRecord::Migration[5.2]
  def up
    BackfillUploaderScopesWorker.perform_async
  end
end
