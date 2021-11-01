# frozen_string_literal: true

class BackfillNonMemberClientsToDefaultCompanyMembership < ActiveRecord::Migration[5.2]
  def up
    BackfillNonMemberClientsToDefaultCompanyMembershipWorker.perform_async
  end
end
