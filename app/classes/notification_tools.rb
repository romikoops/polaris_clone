module NotificationTools
  include MongoTools

  # def get_messages_for_user(user)
  #   query = [{'tenant_id' => {"$eq" => user.tenant_id}}, {"user_id" => {"$eq" => user.id}}]
  #   resp = get_items_query('messages', query)
  #   return resp.to_a
  # end
  def get_messages_for_user(user)
    conversations = user.conversations
    unread = conversations.flat_map {|c| c.messages.where(read:false)}.count
    resp = {"conversations" => conversations, "unread" => unread}
    return resp
  end

  def get_messages_for_admin(user)
    conversations = user.tenant.conversations.each_with_object(Hash.new(0)) do |conversation, return_h|
      return_h[conversation.shipment.imc_reference] = conversation.messages.order(:updated_at)
    end
    unread = user.tenant.conversations.flat_map {|c| c.messages.where(read:false)}.count
    
    master_resp = {"conversations" => conversations, "unread" => unread}
    return master_resp
  end
  def get_messages_for_manager(user)
    conversations = Conversation.where(manager_id: user.id)
    unread = conversations.flat_map {|c| c.messages.where(read:false)}.count

    resp = {"conversations" => conversations, "unread" => unread}
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
    data = message.deep_symbolize_keys
    ref = data.delete(:shipmentRef)
    shipment = Shipment.find_by_imc_reference(ref)
    data[:sender_id] = shipment.user.id
    conversation = shipment.conversations.find_or_create_by!(user_id: shipment.user.id, tenant_id: user.tenant_id, shipment_id: shipment.id)
    new_message = conversation.messages.create!(data)
    return {message: new_message, shipmentRef: ref}
  end
end
