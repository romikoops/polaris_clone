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

  def seed_init_table(table_name, primary_key)
    client = init
    params = {
      table_name: table_name,
      key_schema: [
        {
          attribute_name: "#{primary_key}",
          key_type: 'HASH'  #Partition key
        }
      ],
      attribute_definitions: [
        {
          attribute_name: "#{primary_key}",
          attribute_type: 'S'
        }
      ],
      provisioned_throughput: {
        read_capacity_units: 5,
        write_capacity_units: 5
      }
    }

    begin
      result = client.create_table(params)

      puts 'Created table. Status: ' +
        result.table_description.table_status;
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts 'Unable to create table:'
      puts error.message
    end
  end

  private

  def init
    #dynamodb = Aws::DynamoDB::Client.new(
    #   region: 'eu-central-1',
    #   access_key_id: ENV['AWS_KEY'],
    #   secret_access_key: ENV['AWS_SECRET']
    # )
    dynamodb = Aws::DynamoDB::Client.new(
      access_key_id: 'key',
      secret_access_key: 'key',
      endpoint:'http://localhost:8000'
    )

    return dynamodb
  end
end
