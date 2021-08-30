# frozen_string_literal: true

module ExcelDataServices
  class Upload < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :file, class_name: "Legacy::File"
    belongs_to :user, class_name: "Users::User", optional: true
    enum status: { not_started: "not_started", superseded: "superseded", processing: "processing", failed: "failed", done: "done" }, _prefix: true

    accepts_nested_attributes_for :file
  end
end

# == Schema Information
#
# Table name: excel_data_services_uploads
#
#  id              :uuid             not null, primary key
#  status          :enum             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  file_id         :uuid             not null
#  last_job_id     :uuid
#  organization_id :uuid             not null
#  user_id         :uuid
#
# Indexes
#
#  index_excel_data_services_uploads_on_file_id          (file_id)
#  index_excel_data_services_uploads_on_last_job_id      (last_job_id)
#  index_excel_data_services_uploads_on_organization_id  (organization_id)
#  index_excel_data_services_uploads_on_status           (status)
#  index_excel_data_services_uploads_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (file_id => legacy_files.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (user_id => users_users.id)
#
