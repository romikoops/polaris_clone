# frozen_string_literal: true

class GenerateLocationGroups < ActiveRecord::Migration[5.2]
  def up
    GenerateLocationGroupsWorker.perform_async
  end
end
