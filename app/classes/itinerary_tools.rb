module ItineraryTools
  include MongoTools
  def get_itineraries_with_dedicated_pricings(user_id, tenant_id)
    query = [
      { "tenant_id"  => {"$eq" => tenant_id} }, 
      { "#{user_id}" => {"$exists" => true} }
    ]
    itinerary_pricings = get_items_query('itineraryPricings', query)
    return itinerary_pricings.map { |itinerary_pricing| itinerary_pricing["itinerary"] }.uniq
  end

  def get_itinerary_pricings(itinerary_id, transport_category_ids)
    query = [ 
      { "itinerary_id" => { "$eq" => itinerary_id } }, 
      { "transport_category_id" => { "$in" => transport_category_ids } }
    ]
    itinerary_pricings = get_items_query('itineraryPricings', query)
    return itinerary_pricings.to_a
  end

  def get_itinerary_option(itinerary)
    query = [
      { 
        "$match" => { "id" => itinerary.tenant_id } 
      },
      { 
        "$project" => {
          "data" => { 
            "$filter" => {
              "input" => "$data",
              "as"    => "itinerary",
              "cond"  => { "$eq" => ["$$itinerary.id", itinerary.id]},
            }
          }
        }
      }
    ]
    return get_items_aggregate("itineraryOptions", query)
  end

  def get_itinerary_options(itinerary)
    query = [
      { 
        "$match" => { "id" => itinerary.tenant_id } 
      },
      { 
        "$project" => {
          "data" => { 
            "$filter" => {
              "input" => "$data",
              "as"    => "itinerary",
              "cond"  => { "$eq" => ["$$itinerary.id", itinerary.id]},
            }
          }
        }
      }
    ]
    return get_items_aggregate("itineraryOptions", query)
  end

  def get_itineraries(tenant_id)
    resp = get_item("itineraryOptions", "id", tenant_id)
    return resp["data"]
  end

  def get_scoped_itineraries(tenant_id, mot_scope_ids)
    query = [
      { 
        "$match" => { "id" => tenant_id } 
      },
      { 
        "$project" => {
          "data" => { 
            "$filter" => {
              "input" => "$data",
              "as"    => "itinerary",
              "cond"  => { "$in" => ["$$itinerary.mot_scope_id", mot_scope_ids]},
            }
          }
        }
      }
    ]
    return get_items_aggregate("itineraryOptions", query)
  end

  def update_itinerary_option(itinerary)
    return if get_itinerary_option(itinerary).empty?

    update = itinerary.attributes.each_with_object({}) do |(k, v), h|
      h["data.$.#{k}"] = v
    end

    key = { "$and" => [
        { "id" => { "$eq" => itinerary.tenant.id } },
        { "data.id" => { "$eq" => itinerary.id } }
      ]
    }
    update_item('itineraryOptions', key, update)
  end

  def retrieve_route_options(tenant_id, ids)
    client = init
    resp = client["itineraryOptions"].aggregate([
      { "$match" => { "id" => tenant_id }},
      {"$project" => {
          data: {"$filter" => {
              input: '$data',
              as: 'ro',
              cond: {"$in" => ["$$ro.id", ids]}
          }},
          _id: 0
        }
      }
    ])
    p "resp achieved"
    return resp.to_a.first["data"]
  end
end
