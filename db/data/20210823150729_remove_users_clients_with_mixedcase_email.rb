# frozen_string_literal: true

class RemoveUsersClientsWithMixedcaseEmail < ActiveRecord::Migration[5.2]
  def up
    RemoveUsersClientsWithMixedcaseEmailWorker.perform_async
  end
end
