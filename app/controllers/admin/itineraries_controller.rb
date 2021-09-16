# frozen_string_literal: true

class Admin::ItinerariesController < Admin::AdminBaseController
  def index
    paginated_itineraries = handle_search.paginate(pagination_options)

    response_handler(
      pagination_options.merge(
        itinerariesData: Api::V1::ItineraryDecorator.decorate_collection(paginated_itineraries).map(&:legacy_json),
        numPages: paginated_itineraries.total_pages
      )
    )
  end

  def create
    itinerary = formated_itinerary
    if itinerary.save
      response_handler(itinerary.as_json)
    else
      response_handler(app_error(itinerary.errors.full_messages.join("\n")))
    end
  end

  def destroy
    response_handler(Itinerary.find_by(id: params[:id]).destroy)
  end

  def stops
    response_handler(itinerary_stops.map { |stop| stop_index_json(stop: stop) })
  end

  def edit_notes
    response_handler(itinerary_with_notes)
  end

  def show
    itinerary = Itinerary.find_by(id: params[:id])
    resp = {
      itinerary: itinerary,
      validationResult: Validator::Itinerary.new(user: organization_user, itinerary: itinerary).perform,
      notes: itinerary.notes
    }
    response_handler(resp)
  end

  private

  def handle_search
    itinerary_relation = ::Legacy::Itinerary.where(organization: current_organization)

    {
      origin: ->(query, param) { query.origin_search(param) },
      destination: ->(query, param) { query.destination_search(param) },
      name: ->(query, param) { query.list_search(param) },
      name_desc: ->(query, param) { query.ordered_by(:name, param) },
      mot: ->(query, param) { query.where(mode_of_transport: param) },
      mot_desc: ->(query, param) { query.ordered_by(:mode_of_transport, param) },
      transshipment: ->(query, param) { query.transshipment_search(param) },
      transshipment_desc: ->(query, param) { query.ordered_by(:transshipment, param) }
    }.each do |key, lambd|
      itinerary_relation = lambd.call(itinerary_relation, search_params[key]) if search_params[key]
    end

    itinerary_relation
  end

  def pagination_options
    {
      page: current_page,
      per_page: (params[:page_size] || params[:per_page] || 1).to_i
    }.compact
  end

  def current_page
    params[:page]&.to_i || 1
  end

  def search_params
    params.permit(
      :mot,
      :mot_desc,
      :transshipment,
      :transshipment_desc,
      :name_desc,
      :name,
      :origin_desc,
      :origin,
      :destination_desc,
      :destination,
      :page_size,
      :per_page
    )
  end

  def first_sheet
    xlsx = open_file(params["xlsx"])
    xlsx.sheet(xlsx.sheets.first)
  end

  def itinerary_params
    {
      mode_of_transport: params["itinerary"]["mot"],
      name: params["itinerary"]["name"],
      organization_id: current_organization_id
    }
  end

  def as_json_itineraries
    itineraries = Itinerary.where(organization: current_organization)
    itineraries.map(&:as_options_json)
  end

  def params_stops
    params["itinerary"]["stops"].map.with_index { |h, i| Stop.new(hub_id: h, index: i) }
  end

  def app_error(message)
    ApplicationError.new(
      http_code: 400,
      code: SecureRandom.uuid,
      message: message
    )
  end

  def formated_itinerary
    itinerary = Itinerary.find_or_initialize_by(itinerary_params)
    itinerary.stops = params_stops
    itinerary
  end

  def itinerary_stops
    itinerary = Itinerary.find_by(id: params[:id])
    itinerary.stops.order(:index)
  end

  def itinerary_with_notes
    itinerary = Itinerary.find_by(id: params[:id])
    itinerary.notes.find_or_create_by!(body: params[:notes][:body],
                                       header: params[:notes][:header],
                                       level: params[:notes][:level])
    itinerary.notes
  end

  def new_ids
    @new_ids ||= []
  end

  def old_ids
    Itinerary.pluck(:id)
  end

  def kicked_itinerary_ids
    old_ids - new_ids
  end

  def destroy_itins
    Itinerary.where(id: kicked_itinerary_ids).destroy_all
  end
end
