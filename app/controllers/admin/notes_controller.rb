# frozen_string_literal: true

class Admin::NotesController < ApplicationController
  def upload
    Document.create!(
      text: "#{current_tenant.subdomain}:notes",
      doc_type: 'notes',
      sandbox: @sandbox,
      tenant: current_tenant,
      file: upload_params[:file]
    )

    file = upload_params[:file].tempfile
    options = { tenant: current_tenant,
                file_or_path: file,
                options: { sandbox: @sandbox, user: current_user, group_id: upload_params[:group_id] } }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  private

  def upload_params
    params.permit(:file, :mot, :load_type, :group_id)
  end
end
