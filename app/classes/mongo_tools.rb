module MongoTools # TODO: replace
  require 'mongo'

  def put_item(table, value)
    client = init
    client[table.to_sym].insert_one(value)
  end

  def put_items(table, valueArr)
    client = init
    resp = client[table.to_sym].insert_many(valueArr)
  end

  def update_item(table, key, updates)
    client = init
    resp = client[table.to_sym].update_one(key, {'$set' => updates}, {upsert: true})
  end

  def get_item(table, keyName, key)
    client = init
    resp = client[table.to_sym].find({"#{keyName}" => key})
    return resp.first
  end

  def get_items(table, keyName, key)
    client = init
    resp = client[table.to_sym].find({"#{keyName}" => key})
    return resp
  end

  def get_items_fn(client, table, keyName, key)
    resp = client[table.to_sym].find({"#{keyName}" => key})
    return resp.to_a
  end

  def get_item_fn(client, table, keyName, key)
    resp = client[table.to_sym].find({"#{keyName}" => "#{key}"})
    return resp.first
  end

  def get_all_items(table)
    client = init
    resp = client[table.to_sym].find({})
    return resp.to_a
  end

  def query_table(table, key, query)
    client = init
    resp = client[table.to_sym].find(key, query)
    return resp.to_a
  end

  def get_items_by_key_values(client, table, key, values)
    if !client
      client = get_client
    end
    resp = client[table.to_sym].find(key => {"$in" => values})
    return resp.to_a
  end

  def get_items_query(table,  query)
    client = init
    resp = client[table.to_sym].find({"$and" => query})
    return resp
  end

  def get_items_query_fn(client, table,  query)
    resp = client[table.to_sym].find({"$and" => query})
    return resp
  end

  def get_client
    client = $db
    return client
  end

  def put_item_fn(client, table, value)
    client[table.to_sym].insert_one(value)
  end
  
  def put_items_fn(client, table, valueArr)
    resp = client[table.to_sym].insert_many(valueArr)
  end

  def update_item_fn(client, table, key, updates)
    client[table.to_sym].update_one(key, {'$set' => updates}, {upsert: true})
  end
 
  def text_search_fn(client, table, query)
    if !client
      client = get_client
    end
    resp = client[table.to_sym].find(
      { "$text" => { "$search" => query } }, 
      projection: { "score" => { "$meta" => "textScore" }}
    )
    resp.to_a
  end

  def update_array_fn(client, table, key, updates)
    updateArr = {}
    updateArr = {data: {'$each' => updates}}
    # updateArr = {'$each' => updates}
    p updateArr
    client[table.to_sym].update_one(key, {'$push' => updateArr}, {upsert: true})
  end
  def update_array(table, key, updates)
    client = init
    updateArr = {}
    updateArr = {data: {'$each' => updates}}
    # updateArr = {'$each' => updates}
    p updateArr
    client[table.to_sym].update_one(key, {'$push' => updateArr}, {upsert: true})
  end
  
  def get_items_aggregate(table, query)
    client = init
    resp = client[table].aggregate(query)
    return resp.first ? resp.first["data"] : []
  end

  def delete_item(table, query)
    client = init
    client[table].delete_one(query)
  end

  def drop_table(table)
    client = init
    client[table].drop
  end

  private

  def init
    return $db
  end
end
