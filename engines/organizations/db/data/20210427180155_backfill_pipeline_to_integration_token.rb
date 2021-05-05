# frozen_string_literal: true

class BackfillPipelineToIntegrationToken < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    Organizations::IntegrationToken
      .where(pipeline: nil)
      .each { |record| record.update(pipeline: "okargo") }
  end
end
