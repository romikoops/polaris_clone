# frozen_string_literal: true

Trestle.resource(:interactions, model: Tracker::Interaction) do
  menu :interactions, icon: "fa fa-globe", group: :tracker

  collection do
    Tracker::Interaction.order(created_at: :desc)
  end

  instance do |params|
    Tracker::Interaction.find(params[:id])
  end

  table do
    column :name

    actions
  end

  form do |_interaction|
    text_field :name
  end
end
