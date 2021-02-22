# frozen_string_literal: true
class AddBTreeGistExtension < ActiveRecord::Migration[5.2]
  def change
    enable_extension :btree_gist
  end
end
