# frozen_string_literal: true
class BackfillWrongLocodesAndHubCodes < ActiveRecord::Migration[5.2]
  def up
    BackfillWrongLocodesAndHubCodesWorker.perform_async
  end
end
