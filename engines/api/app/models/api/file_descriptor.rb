# frozen_string_literal: true

module Api
  class FileDescriptor < ::Files::FileDescriptor
  end
end

# == Schema Information
#
# Table name: files_file_descriptors
#
#  id                      :uuid             not null, primary key
#  file_added_to_source_at :string
#  file_created_at         :string
#  file_path               :string           not null
#  file_type               :string           not null
#  file_updated_at         :string
#  originator              :string           not null
#  source                  :string           not null
#  source_type             :string           not null
#  status                  :enum             not null
#  synced_at               :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :uuid
#
# Indexes
#
#  index_files_file_descriptors_on_file_path                      (file_path)
#  index_files_file_descriptors_on_organization_id                (organization_id)
#  index_files_file_descriptors_on_organization_id_and_file_path  (organization_id,file_path) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
