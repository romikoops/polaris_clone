class AddLatestUpdateToConversations < ActiveRecord::Migration[5.1]
  def change
    add_column :conversations, :last_updated, :datetime
    add_column :conversations, :unreads, :integer
  end
end
