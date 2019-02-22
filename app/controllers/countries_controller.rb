# frozen_string_literal: true

class CountriesController < ApplicationController
  def index
    @countries = Country.all
    response_handler(countries: @countries)
  end
end
