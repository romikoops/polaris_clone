# frozen_string_literal: true

Trestle.resource(:themes, model: Organizations::Theme) do
  menu :themes, icon: "fa fa-paint-brush", group: :organizations

  form do |_theme|
    text_field :name

    row do
      col(sm: 6) { text_field :primary_color }
      col(sm: 6) { text_field :secondary_color }
    end

    row do
      col(sm: 6) { text_field :bright_primary_color }
      col(sm: 6) { text_field :bright_secondary_color }
    end

    %i[
      background
      small_logo
      large_logo
      email_logo
      white_logo
      wide_logo
      booking_process_image
    ].each do |attachment|
      row do
        col(sm: 4) { file_field attachment }
        col(sm: 8) { organization.theme.send(attachment).attached? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(organization.theme.send(attachment)), width: "100px") : "No Content" }
      end
    end
  end
end
