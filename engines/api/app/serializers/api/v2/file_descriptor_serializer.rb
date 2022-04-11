# frozen_string_literal: true

module Api
  module V2
    class FileDescriptorSerializer < Api::ApplicationSerializer
      attributes %i[organization_id file_path file_type
        originator source source_type status file_created_at file_updated_at synced_at]
    end
  end
end
