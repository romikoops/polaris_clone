# frozen_string_literal: true

class Admin::TruckingController < Admin::AdminBaseController
  include ExcelTools
  include TruckingTools

  def index
    response_handler({})
  end

  def show
    hub = Hub.find(params[:id])
    results = Trucking::Rate.find_by_hub_id(params[:id])
    response_handler(hub: hub, truckingPricings: results)
  end

  def edit
    tp = Trucking::Rate.find(params[:id])
    ntp = params[:pricing].as_json
    tp.update_attributes(ntp.except('id', 'cargo_class', 'load_type', 'courier_id', 'truck_type', 'carriage'))
    response_handler(tp)
  end

  def create
    do_for_create
    response_handler(truckingHubId: truckingHubId)
  end

  def overwrite_zonal_trucking_by_hub
    if params[:file]
      req = { "xlsx" => params[:file] }
      resp = Trucking::Excel::Inserter.new(
        params: req,
        hub_id: params[:id]
      ).perform

      response_handler(resp)
    else
      response_handler(false)
    end
  end

  def download
    options = params[:options].as_json.symbolize_keys
    options[:tenant_id] = current_user.tenant_id
    url = DocumentService::TruckingWriter.new(options).perform
    response_handler(url: url, key: 'trucking')
  end

  private

  def clone_dv(key, value, keys = %w(upper lower))
    if key.include?(keys[0]) || key.include?(keys[1])
      value.clone.to_f
    else
      value.clone
    end
  end

  def create_query(dv) # rubocop:disable Naming/UncommunicativeMethodParamName
    query = {}
    dv.each do |key, val|
      query[key] = clone_dv(key, val)
    end
    query
  end

  def populate_query_holder(dv, dir, dk) # rubocop:disable Naming/UncommunicativeMethodParamName
    query_holder[dir][dk] = [] unless query_holder[dir][dk]

    query = create_query(dv)
    query.delete('table')
    query[:modifier] = meta['subModifier']
    query[:direction] = dir
    query[:trucking_hub_id] = truckingHubId

    query_holder[dir][dk] << query
  end

  def data
    @data ||= params[:obj][:data].as_json
  end

  def meta
    @meta ||= params[:obj][:meta].as_json
  end

  def global
    @global ||= params[:obj][:global].as_json
  end

  def query_holder
    @query_holder ||= {}
  end

  def truckingQueries # rubocop:disable Naming/MethodName
    @truckingQueries ||= []
  end

  def truckingPricings # rubocop:disable Naming/MethodName
    @truckingPricings ||= []
  end

  def directions
    @directions ||= meta['direction'] == 'either' ? %w(import export) : [meta['direction']]
  end

  def truckingHubId # rubocop:disable Naming/MethodName
    @truckingHubId = "#{meta['nexus_id']}_#{meta['loadType']}_#{current_user.tenant_id}"
  end

  def iterate_and_populate_query_holder
    data.each do |d|
      d.each do |dk, dv|
        populate_query_holder(dv, dir, dk)
      end
    end
  end

  def update_query_holder_and_truckingqueries(dir)
    query_holder[dir].each do |key, vals|
      p vals.uniq
      query_holder[dir][key] = v.uniq[0]
      query_holder[dir][key][:_id] = SecureRandom.uuid
      truckingQueries << query_holder[dir][key]
    end
  end

  def temp_hash(dt) # rubocop:disable Naming/UncommunicativeMethodParamName
    tmp = {}
    dt.each do |key, val|
      tmp[key] = clone_dv(key, val, %w(min max))
    end
    tmp
  end

  def populate_trucking_pricing(dir, dk, dv) # rubocop:disable Naming/UncommunicativeMethodParamName
    query = query_holder[dir][dk]
    dv['table'].each_with_index do |dt, _i|
      tmp = temp_hash(dt)
      tmp[:_id] = SecureRandom.uuid
      tmp['type'] = dk
      tmp['trucking_hub_id'] = truckingHubId
      tmp['trucking_query_id'] = query[:_id]
      tmp['tenant_id'] = current_user.tenant_id
      truckingPricings << tmp
    end
  end

  def iterate_and_populate_trucking_pricings
    data.each do |d|
      d.each do |dk, dv|
        populate_trucking_pricing(dir, dk, dv)
      end
    end
  end

  def update_item_truckingPricings # rubocop:disable Naming/MethodName
    truckingPricings.each do |k|
      update_item('truckingPricings', { _id: k[:_id] }, k)
    end
  end

  def update_item_truckingQueries # rubocop:disable Naming/MethodName
    truckingQueries.each do |k|
      update_item('truckingQueries', { _id: k[:_id] }, k)
    end
  end

  def update_item_truckingHubs # rubocop:disable Naming/MethodName
    update_item('truckingHubs',
                { _id: truckingHubId },
                type: meta['type'].to_s,
                load_type: meta['loadType'],
                modifier: meta['modifier'].to_s,
                tenant_id: current_user.tenant_id,
                nexus_id: meta['nexus_id'])
  end

  def do_for_create
    directions.each do |dir|
      query_holder[dir] = {} unless query_holder[dir]
      iterate_and_populate_query_holder
      update_query_holder_and_truckingqueries(dir)
      iterate_and_populate_trucking_pricings
    end
    update_item_truckingPricings
    update_item_truckingQueries
    update_item_truckingHubs
  end
end
