# frozen_string_literal: true

Trestle.resource(:carriers, model: Admiralty::Carrier) do
  menu :carriers, icon: "fa fa-ship", group: :routing

  search do |query|
    if query
      query = if (match = query.match(/\A"(.*)"\z/))
        match[1]
      else
        "%#{query}%"
      end

      collection.where("name ILIKE :query", query: query)
    else
      collection
    end
  end

  table do
    column :logo, header: false, align: :center, blank: nil do |carrier|
      image_tag(Rails.application.routes.url_helpers.rails_blob_url(carrier.logo), width: "100px", height: "75px") if carrier.logo.attached?
    end
    column :code
    column :name

    actions
  end

  form do |carrier|
    row do
      col(sm: 6) do
        col(sm: 10) { file_field :logo, label: "Logo", help: "Carrier logo for display on the site" }
        col(sm: 10) { image_tag(Rails.application.routes.url_helpers.rails_blob_url(carrier.logo)) if carrier.logo.attached? }
      end
      col(sm: 6) { text_field :name, label: "Name", help: "Carrier Name" }
      col(sm: 6) { text_field :code, label: "Code", help: "Carrier Code" }
    end
  end
end
