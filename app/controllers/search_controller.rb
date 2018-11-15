# frozen_string_literal: true

class SearchController < ApplicationController
  include Response
  include MongoTools
  before_action :require_login

  def search_hs_codes
    text = params[:query] != '' ? params[:query] : 'plastics'
    resp = text_search_fn(false, 'hsCodes', text)
    results = []
    resp.each do |r|
      if !current_tenant.scope['dangerous_goods'] && !r['dangerous']
        tmp = {}
        tmp['label'] = r['text']
        tmp['value'] = r['_id']
        results << tmp

      elsif current_tenant.scope['dangerous_goods'] && r['dangerous']
        tmp = {}
        tmp['label'] = r['text']
        tmp['value'] = r['_id']
        results << tmp

      end
    end
    response_handler(results)
  end

  private

  def require_login
    unless user_signed_in? && current_user && current_user.tenant_id == params[:tenant_id]
      flash[:error] = 'You are not authorized to access this section.'
      redirect_to root_path
    end
  end
end
