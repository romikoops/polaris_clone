# frozen_string_literal: true

Trestle.resource(:max_dimensions_bundles, model: Legacy::MaxDimensionsBundle) do
  menu :max_dimensions_bundles, icon: "fa fa-ruler-combined", group: :organizations

  search do |query|
    if query
      query = if (match = query.match(/\A"(.*)"\z/))
        match[1]
      else
        "%#{query}%"
      end

      collection
        .joins(:organization)
        .where("organizations_organizations.slug ILIKE :query", query: query)
    else
      collection
    end
  end

  table do
    column :organization, ->(max_dimensions_bundle) { max_dimensions_bundle.organization.slug }

    column :aggregate
    column :cargo_class
    column :mode_of_transport

    column :length
    column :width
    column :height
    column :payload_in_kg
    column :volume
    column :chargeable_weight

    column :carrier, ->(max_dimensions_bundle) { max_dimensions_bundle.carrier&.name }
    column :tenant_vehicle, ->(max_dimensions_bundle) { max_dimensions_bundle.tenant_vehicle&.name }

    actions
  end

  form do |max_dimensions_bundle|
    collection_select :organization_id, Organizations::Organization.all, :id, :slug

    collection_select :tenant_vehicle_id,
      Legacy::TenantVehicle.where(organization_id: max_dimensions_bundle.organization_id),
      :id, :name, { include_blank: true, prompt: "- None -" }
    collection_select :carrier_id,
      Legacy::Carrier.order(:name), :id, :name, { include_blank: true, prompt: "- None -" }

    row do
      col(sm: 4) { check_box :aggregate }
      col(sm: 4) { select :cargo_class, Cargo::Creator::LEGACY_CARGO_MAP.keys.sort }
      col(sm: 4) { select :mode_of_transport, Legacy::MaxDimensionsBundle::MODES_OF_TRANSPORT.sort }
    end

    row do
      col(sm: 4) { number_field :length, label: "Length", help: "Maximum length of a single cargo unit." }
      col(sm: 4) { number_field :width, label: "Width", help: "Maximum width of a single cargo unit." }
      col(sm: 4) { number_field :height, label: "Height", help: "Maximum height of a single cargo unit." }
    end

    row do
      col(sm: 4) { number_field :payload_in_kg, label: "Payload (kg)", help: "Maximum weight of a single cargo unit." }
      col(sm: 4) { number_field :volume, label: "Volume (㎥)", help: "Maximum volume of a single cargo unit." }
      col(sm: 4) { number_field :chargeable_weight, label: "Chargeable Weight", help: "Maximum cargeable weight per cargo unit." }
    end
  end
end
