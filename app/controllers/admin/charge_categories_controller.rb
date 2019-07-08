# frozen_string_literal: true

class Admin::ChargeCategoriesController < Admin::AdminBaseController # rubocop:disable # Style/ClassAndModuleChildren
  def upload
    file = upload_params[:file].tempfile

    options = { tenant: current_tenant,
                file_or_path: file,
                options: { sandbox: @sandbox, user: current_user } }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  def download
    file_name = "#{current_tenant.subdomain.downcase}__charge_categories"
    klass_identifier = 'ChargeCategories'
    key = 'charge_categories'

    options = {
      tenant: current_tenant,
      specific_identifier: klass_identifier,
      file_name: file_name,
      sandbox: @sandbox
    }
    downloader = ExcelDataServices::Loaders::Downloader.new(options)
    document = downloader.perform

    # TODO: When timing out, file will not be downloaded!!!
    response_handler(key: key, url: rails_blob_url(document.file, disposition: 'attachment'))
  end

  private

  def upload_params
    params.permit(:file)
  end

  def download_params
    params.require(:options).permit(:mot)
  end
end
