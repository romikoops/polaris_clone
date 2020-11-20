# frozen_string_literal: true

class Admin::ChargeCategoriesController < Admin::AdminBaseController # rubocop:disable # Style/ClassAndModuleChildren
  def upload
    handle_upload(
      params: upload_params,
      text: "#{current_organization.slug}_charge_categories",
      type: "charge_categories",
      options: {
        user: organization_user
      }
    )
  end

  def download
    category_identifier = "charge_categories"
    file_name = "#{current_organization.slug}__#{category_identifier}"

    document = ExcelDataServices::Loaders::Downloader.new(
      organization: current_organization,
      category_identifier: category_identifier,
      file_name: file_name
    ).perform

    # TODO: When timing out, file will not be downloaded!!!
    response_handler(
      key: category_identifier,
      url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: "attachment")
    )
  end

  private

  def upload_params
    params.permit(:async, :file)
  end

  def download_params
    params.require(:options).permit(:mot)
  end
end
