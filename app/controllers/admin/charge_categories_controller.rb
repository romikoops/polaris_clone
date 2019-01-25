# frozen_string_literal: true

class Admin::ChargeCategoriesController < Admin::AdminBaseController

  def upload
    file = upload_params[:file].tempfile

    options = { tenant: current_tenant, file_or_path: file }
    sheets_data = ExcelDataServices::FileParser::ChargeCategories.new(options).perform

    options = { tenant: current_tenant, data: sheets_data }
    insertion_stats = ExcelDataServices::DatabaseInserter::ChargeCategories.new(options).perform

    response_handler(insertion_stats)
  end

  def download
    file_name = "#{current_tenant.subdomain.downcase}__charge_categories"

    options = { tenant: current_tenant, file_name: file_name}
    document = ExcelDataServices::FileWriter::ChargeCategories.new(options).perform

    response_handler(key: 'charge_categories', url: rails_blob_url(document.file, disposition: 'attachment'))
  end


  private

  def upload_params
    params.permit(:file)
  end

  def download_params
    params.require(:options).permit(:mot)
  end
end
