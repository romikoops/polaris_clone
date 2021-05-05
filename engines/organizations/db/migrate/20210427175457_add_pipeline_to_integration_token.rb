# frozen_string_literal: true

class AddPipelineToIntegrationToken < ActiveRecord::Migration[5.2]
  def up
    add_column :organizations_integration_tokens, :pipeline, :string
    change_column_default :organizations_integration_tokens, :pipeline, "default"
  end

  def down
    remove_column :organizations_integration_tokens, :pipeline
  end
end
