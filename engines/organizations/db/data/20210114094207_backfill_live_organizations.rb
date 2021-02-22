# frozen_string_literal: true
class BackfillLiveOrganizations < ActiveRecord::Migration[5.2]
  def up
    Organizations::BackfillLiveOrganizationsWorker.perform_async
  end
end
