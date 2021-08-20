# frozen_string_literal: true

class RemoveDeletedGroupMembershipsNilMembers < ActiveRecord::Migration[5.2]
  def up
    RemoveDeletedGroupMembershipsNilMembersWorker.perform_async
  end
end
