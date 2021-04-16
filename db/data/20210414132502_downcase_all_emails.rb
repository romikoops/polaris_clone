# frozen_string_literal: true

class DowncaseAllEmails < ActiveRecord::Migration[5.2]
  def up
    DowncaseAllEmailsWorker.perform_async
  end
end
