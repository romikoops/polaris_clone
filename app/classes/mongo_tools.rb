module MongoTools
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
    resp = client[table.to_sym].update_one(key, {'$set' => updates})
  end

  def get_item(table, keyName, key)
    client = init
    resp = client[table.to_sym].find({"#{keyName}" => "#{key}"})
    return resp.first
  end

  def get_items(table, keyName, key)
    client = init
    resp = client[table.to_sym].find({"#{keyName}" => key})
    return resp
  end

  def get_items_query(table, query)
    client = init
    resp = client[table.to_sym].find({"$and" => query})
    return resp
  end

  def get_client
    client = init
    return client
  end

  def put_item_fn(client, table, value)
    client[table.to_sym].insert_one(value)
  end

  def update_item_fn(client, table, key, updates)
    client[table.to_sym].update_one(key, {'$set' => updates}, {upsert: true})
  end

  def get_item_fn(client, table, keyName, key)
    resp = client[table.to_sym].find({"#{keyName}" => "#{key}"})
    return resp.first
  end

  private

  def init
    # if Rails.env == 'development'
    #   client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'development')
    # else
    client = Mongo::Client.new('mongodb://imcdbadmin:DZYKIdOZk3vP6erN@staging-shard-00-00-sco92.mongodb.net:27017,staging-shard-00-01-sco92.mongodb.net:27017,staging-shard-00-02-sco92.mongodb.net:27017/test?ssl=true&replicaSet=Staging-shard-0&authSource=admin')
    # end
    return client
  end
end
