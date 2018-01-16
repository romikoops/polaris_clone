module NotificationTools
  include MongoTools

  def get_messages_for_user(user)
    query = [{'tenant_id' => {"$eq" => user.tenant_id}}, {"user_id" => {"$eq" => user.id}}]
    resp = get_items_query('messages', query)
    return resp.to_a
  end

  def add_message_to_convo(user, message)
    data = message
    data["tenant_id"] = user.tenant_id
    data["user_id"] = user.id
    data["timestamp"] = Time.now.to_i
    data["read"] = false
    convo_id = "#{user.tenant_id}_#{user.id}"
    $db["messages"].update_one({_id: convo_id}, {"$push" => {messages: data}}, {upsert: true})
    return data
  end
end