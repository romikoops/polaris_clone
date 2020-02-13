# frozen_string_literal: true

class Admin::AdminBaseController < ApplicationController
  before_action :require_login_and_role_is_admin

  protected

  def require_login_and_role_is_admin
    return unless user_signed_in? && current_user.role.name.include?('admin') && is_current_tenant?
  end

  def open_file(file)
    Roo::Spreadsheet.open(file)
  end

  def is_current_tenant?
    current_user.tenant_id == params[:tenant_id].to_i
  end

  def handle_upload(params:, text:, type:, options: {})
    document = Legacy::File.create!(
      text: text,
      doc_type: type,
      sandbox: @sandbox,
      tenant: current_tenant,
      file: params[:file]
    )

    file = params[:file].tempfile
    options = { tenant: current_tenant,
                file_or_path: file,
                options: options.merge(document: document)
              }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    response_handler(uploader.perform)
  end
end
