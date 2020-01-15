# frozen_string_literal: true

class DeprecateNotificationTables < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_table :conversations, 'conversations_20200114'
      rename_table :messages, 'messages_20200114'
    end
  end
end
