# frozen_string_literal: true

class Admin::ChargeCategoriesController < Admin::AdminBaseController # rubocop:disable # Style/ClassAndModuleChildren
  def upload
    Document.create!(
      text: '',
      doc_type: 'charge_categories',
      sandbox: @sandbox,
      tenant: current_tenant,
      file: upload_params[:file]
    )

    file = upload_params[:file].tempfile
    options = { tenant: current_tenant,
                file_or_path: file,
                options: { sandbox: @sandbox, user: current_user } }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  def download
    tenant_slug = ::Tenants::Tenant.find_by(legacy_id: current_tenant.id).slug
    category_identifier = 'charge_categories'
    file_name = "#{tenant_slug}__#{category_identifier}"

    document = ExcelDataServices::Loaders::Downloader.new(
      tenant: current_tenant,
      category_identifier: category_identifier,
      file_name: file_name,
      sandbox: @sandbox
    ).perform

    # TODO: When timing out, file will not be downloaded!!!
    response_handler(
      key: category_identifier,
      url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: 'attachment')
    )
  end

  private

  def upload_params
    params.permit(:file)
  end

  def download_params
    params.require(:options).permit(:mot)
  end
end
