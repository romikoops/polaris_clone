# frozen_string_literal: true

Trestle.resource(:countries, model: Admiralty::Country) do
  menu :countries, icon: "fa fa-map", group: :geodata

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
    column :code
    column :name
    column :locations_enabled?

    actions
  end

  update_instance do |instance, attrs|
    Admiralty::LocationImporter.new(country: instance, file: attrs["csv_data"]).perform if attrs["csv_data"].present?
  end

  form do |_country|
    row do
      col(sm: 6) { file_field :csv_data, label: "CsvData", help: "CSV file with location data in the format 'postcode,id,country,coordinates,geometry'" }
    end

    sidebar do
      link_to(
        "Update From S3!",
        admin.path(:update_from_data_hub, id: instance.id),
        method: :post,
        class: instance.locations_enabled? ? "btn btn-primary btn-block" : "btn btn-primary btn-block disabled"
      )
    end
  end

  controller do
    def update_from_data_hub
      country = admin.find_instance(params)
      Admiralty::LocationImporter.new(country: country).perform
      redirect_to admin.path(:show, id: country)
    end
  end

  routes do
    post :update_from_data_hub, on: :member
  end
end
