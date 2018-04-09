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
    if resp && resp["conversations"]
      resp["conversations"].each do |kc, vc|
        vc["messages"].each do |msg|
          if !msg["read"]
            unread += 1
          end
        end
      end
      resp["unread"] = unread
    else
      resp = {"conversations" => [], "unread" => 0}
    end
    return resp
  end
  def get_messages_for_admin(user)
    resp = get_items('messages', "tenant_id", user.tenant_id).to_a
    unread = 0
    master_resp = {"conversations" => {}, "unread" => 0}
    
    if resp && resp.length > 0
      resp.each do |r|
        if r && r["conversations"]
          r["conversations"].each do |kc, vc|
            vc["messages"].each do |msg|
              if !msg["read"]
                unread += 1
              end
            end
          end
          r["conversations"].each do |k, v|
            master_resp["conversations"][k] = v
          end
          master_resp["unread"] += unread
          else
          r = {"conversations" => [], "unread" => 0}
        end
      end
    end
    return master_resp
  end
  def get_messages_for_manager(user)
    resp = get_item('messages', "tenant_id", user.tenant_id)
    unread = 0
    if resp && resp["conversations"]
      resp["conversations"].each do |kc, vc|
        if vc["manager_ids"] && !vc["manager_ids"][user.id]
          resp["conversations"].delete(kc)
        end
        vc["messages"].each do |msg|
          if !msg["read"]
            unread += 1
          end
        end
      end
      resp["unread"] = unread
      else
      resp = {"conversations" => [], "unread" => 0}
    end
    return resp
  end

  def update_convo(user, messages)
    convo_id = "#{user.tenant_id}_#{user.id}"
    $db["messages"].update_one({_id: convo_id}, messages)
  end

  def update_admin_convo(ref, messages)
    data_point = messages["conversations"][ref]["messages"][0]
    selected_messages = {"conversations" => {}, "tenant_id" => data_point["tenant_id"]}
    
    messages["conversations"].each do |k, v|
      if v["messages"][0]["user_id"] == data_point["user_id"] &&  v["messages"][0]["tenant_id"] == data_point["tenant_id"]
        selected_messages["conversations"][k] = v
      end

    end
    
    convo_id = "#{data_point["tenant_id"]}_#{data_point["user_id"]}"
    $db["messages"].update_one({_id: convo_id}, selected_messages)
  end

  def add_message_to_convo(user, message, admin)
    manager_ids = {}
    user.user_managers.each { |um| manager_ids[um.manager_id] = true  }
    data = message
    ref = message["shipmentRef"] ? message["shipmentRef"] : message[:shipmentRef]
    data["sender_id"] = admin ? user.tenant.get_admin.id : user.id
    data["tenant_id"] = user.tenant_id
    data["user_id"] = user.id
    data["timestamp"] = Time.now.to_i
    data["shipmentRef"] = ref
    data["read"] = false
    convo_id = "#{user.tenant_id}_#{user.id}"
    $db["messages"].update_one({_id: convo_id}, {"$push" => {"conversations.#{ref}.messages" =>  data}, "$set" => {"tenant_id" => user.tenant_id, "conversations.#{ref}.manager_ids" => manager_ids}}, {upsert: true})
    return data
  end
end