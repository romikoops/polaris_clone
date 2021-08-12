# frozen_string_literal: true

class RemoveDuplicateProfilesForAUser < ActiveRecord::Migration[5.2]
  def up
    RemoveDuplicateProfilesForAUserWorker.perform_async
  end
end
