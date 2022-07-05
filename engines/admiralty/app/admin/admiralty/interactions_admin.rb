# frozen_string_literal: true

Trestle.resource(:interactions, model: Tracker::Interaction) do
  menu :interactions, icon: "fa fa-globe", group: :tracker

  collection do
    Tracker::Interaction.unscoped.order(created_at: :desc)
  end

  instance do |params|
    Tracker::Interaction.unscoped.find(params[:id])
  end

  table do
    column :organization, ->(interaction) { interaction.organization.slug }, sort: :organization
    column :name

    actions
  end

  form do |_interaction|
    collection_select :organization_id, Organizations::Organization.all, :id, :slug
    text_field :name
  end
end
