class SearchController < ApplicationController
  include Response
  include MongoTools
  before_action :require_login

  def search_hs_codes
    resp = text_search_fn(false, 'hsCodes', params[:query])
    results = resp.map { |r| 
        tmp = {}
        tmp["label"] = r["text"]
        tmp["value"] = r["id"]
        return tmp
      }
      response_handler(results)
  end

  private
  def require_login
    unless user_signed_in? && current_user
      redirect_to root_path
    end
  end
end
