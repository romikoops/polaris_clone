# frozen_string_literal: true

module Files
  class FileDescriptor < ApplicationRecord
    REQUIRED_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

    before_validation :date_validation
    belongs_to :organization, class_name: "Organizations::Organization"
    validates :file_path, uniqueness: { scope: :organization_id, case_sensitive: false }, presence: true
    validates :file_type, presence: true
    validates :originator, presence: true
    validates :source, presence: true
    validates :source_type, presence: true
    validates :status, presence: true

    enum status: {
      ready: "ready",
      in_progess: "in_progress",
      synced: "synced",
      failed: "failed"
    }

    def date_validation
      %i[file_created_at file_updated_at synced_at].each do |date|
        next if send(date).blank?

        Date.strptime(send(date), REQUIRED_DATE_FORMAT)
      rescue ArgumentError
        errors.add(:date, error_code: "INVALID_DATE", error_message: "supported date format is `YYYY-mm-dd HH:MM:SS`")
      end
    end
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
