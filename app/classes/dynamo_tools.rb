module DynamoTools
  def put_item(table, key, keyName, value)
    client = init
    value["#{key}"] = keyName
    resp = client.put_item({
      item: value, 
        return_consumed_capacity: "TOTAL", 
        table_name: "#{table}", 
    })
  end
  def update_item(table, key, keyName, value)
    client = init
    update_str = 'set '
    upd_val = {}
    value.each do |k, v|
      if k != value.first[0]
        update_str += ', '
      end
      update_str += "user_#{k} = :#{k}r"
      upd_val[":#{k}r"] = v
    end
    # byebug
    p update_str
    resp = client.update_item({
      key: {
        "#{key}" => keyName
      },
      update_expression: update_str,
      expression_attribute_values: upd_val, 
        return_consumed_capacity: "TOTAL", 
        table_name: "#{table}", 
    })
  end
  def get_item(table, keyName, key)
    client = init
    resp = client.get_item({
    key: {
      "#{keyName}" => "#{key}"
    }, 
    table_name: "#{table}", 
  })
  end
  private
  def init
    dynamodb = Aws::DynamoDB::Client.new(
      region: 'eu-central-1',
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET']
    )
    return dynamodb
  end
end