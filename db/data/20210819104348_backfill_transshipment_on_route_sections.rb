# frozen_string_literal: true

class BackfillTransshipmentOnRouteSections < ActiveRecord::Migration[5.2]
  def up
    BackfillTransshipmentOnRouteSectionsWorker.perform_async
  end
end
