# frozen_string_literal: true

class CorrectSacoLocodes < ActiveRecord::Migration[5.2]
  def up
    CorrectSacoLocodesWorker.perform_async
  end
end
