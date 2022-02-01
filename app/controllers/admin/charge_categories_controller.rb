# frozen_string_literal: true

module Admin
  class ChargeCategoriesController < Admin::AdminBaseController # rubocop:disable # Style/ClassAndModuleChildren
    def upload
      handle_upload(
        params: upload_params,
        text: "#{current_organization.slug}_charge_categories",
        type: "charge_categories"
      )
    end

    def download
      category_identifier = "charge_categories"
      file_name = "#{current_organization.slug}__#{category_identifier}"

      handle_download(
        category_identifier: category_identifier,
        file_name: file_name
      )
    end

    private

    def upload_params
      params.permit(:async, :file)
    end
  end
end
