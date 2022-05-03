# frozen_string_literal: true

class BackfillDoorkeeperApplicationsOnDomains < ActiveRecord::Migration[5.2]
  def up
    BackfillDoorkeeperApplicationsOnDomainsWorker.perform_async
  end
end
