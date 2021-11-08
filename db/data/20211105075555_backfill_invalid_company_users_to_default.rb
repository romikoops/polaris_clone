# frozen_string_literal: true

class BackfillInvalidCompanyUsersToDefault < ActiveRecord::Migration[5.2]
  def up
    BackfillInvalidCompanyUsersToDefaultWorker.perform_async
  end
end
