module NotificationTools
  include MongoTools

  # def get_messages_for_user(user)
  #   query = [{'tenant_id' => {"$eq" => user.tenant_id}}, {"user_id" => {"$eq" => user.id}}]
  #   resp = get_items_query('messages', query)
  #   return resp.to_a
  # end
  def get_messages_for_user(user)
    key = "#{user.tenant_id}_#{user.id}"
    resp = get_item('messages', "_id", key)
    unread = 0
    resp["conversations"].each do |kc, vc|
      vc["messages"].each do |msg|
        if !msg["read"]
          unread += 1
        end
      end
    end
    resp["unread"] = unread
    return resp
  end

  def add_message_to_convo(user, message, admin)
    data = message
    ref = message["shipmentRef"]
    data["sender_id"] = admin ? user.tenant.get_admin.id : user.id
    data["tenant_id"] = user.tenant_id
    data["user_id"] = user.id
    data["timestamp"] = Time.now.to_i
    data["shipmentRef"] = ref
    data["read"] = false
    convo_id = "#{user.tenant_id}_#{user.id}"
    $db["messages"].update_one({_id: convo_id}, {"$push" => {"conversations.#{ref}.messages" =>  data}}, {upsert: true})
    return data
  end
end