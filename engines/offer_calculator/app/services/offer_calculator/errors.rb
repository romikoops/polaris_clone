# frozen_string_literal: true

module OfferCalculator
  class Errors
    class Failure < StandardError
      def code
        CODE_LOOKUP.key(self.class)
      end
    end

    NoDrivingTime = Class.new(Failure)
    NoValidPricings = Class.new(Failure)
    NoValidSchedules = Class.new(Failure)
    InvalidRoutes = Class.new(Failure)
    NoRoute = Class.new(Failure)
    HubNotFound = Class.new(Failure)
    NoDirectionsFound = Class.new(Failure)
    InvalidPickupAddress = Class.new(Failure)
    InvalidDeliveryAddress = Class.new(Failure)
    MissingTruckingData = Class.new(Failure)
    InvalidLocalCharges = Class.new(Failure)
    InvalidFreightResult = Class.new(Failure)
    InvalidLocalChargeResult = Class.new(Failure)
    CalculationError = Class.new(Failure)
    RateBuilderError = Class.new(Failure)
    LoadMeterageExceeded = Class.new(Failure)
    TruckingRateNotFound = Class.new(Failure)
    OfferBuilder = Class.new(Failure)
    NoValidOffers = Class.new(Failure)
    NoPreCarriageFound = Class.new(Failure)
    NoOnCarriageFound = Class.new(Failure)
    NoExportFeesFound = Class.new(Failure)
    NoImportFeesFound = Class.new(Failure)
    NoPricingsFound = Class.new(Failure)
    NoManipulatedPreCarriageFound = Class.new(Failure)
    NoManipulatedOnCarriageFound = Class.new(Failure)
    NoManipulatedExportFeesFound = Class.new(Failure)
    NoManipulatedImportFeesFound = Class.new(Failure)
    NoManipulatedPricingsFound = Class.new(Failure)
    InvalidDirection = Class.new(Failure)
    InvalidCargoUnit = Class.new(Failure)
    LocationNotFound = Class.new(Failure)

    CODE_LOOKUP = {
      1000 => OfferCalculator::Errors::NoRoute,
      1001 => OfferCalculator::Errors::InvalidRoutes,
      1002 => OfferCalculator::Errors::InvalidPickupAddress,
      1003 => OfferCalculator::Errors::InvalidDeliveryAddress,
      1004 => OfferCalculator::Errors::NoValidSchedules,
      1005 => OfferCalculator::Errors::NoDirectionsFound,
      1006 => OfferCalculator::Errors::NoDrivingTime,
      1008 => OfferCalculator::Errors::HubNotFound,
      1009 => OfferCalculator::Errors::InvalidCargoUnit,
      1010 => OfferCalculator::Errors::InvalidDirection,
      1011 => OfferCalculator::Errors::LocationNotFound,
      2001 => OfferCalculator::Errors::NoValidPricings,
      2003 => OfferCalculator::Errors::InvalidLocalChargeResult,
      2004 => OfferCalculator::Errors::InvalidFreightResult,
      2005 => OfferCalculator::Errors::InvalidLocalCharges,
      2007 => OfferCalculator::Errors::CalculationError,
      2008 => OfferCalculator::Errors::RateBuilderError,
      2009 => OfferCalculator::Errors::NoPricingsFound,
      2010 => OfferCalculator::Errors::NoPreCarriageFound,
      2011 => OfferCalculator::Errors::NoOnCarriageFound,
      2012 => OfferCalculator::Errors::NoExportFeesFound,
      2013 => OfferCalculator::Errors::NoImportFeesFound,
      2014 => OfferCalculator::Errors::NoManipulatedPricingsFound,
      2015 => OfferCalculator::Errors::NoManipulatedPreCarriageFound,
      2016 => OfferCalculator::Errors::NoManipulatedOnCarriageFound,
      2017 => OfferCalculator::Errors::NoManipulatedExportFeesFound,
      2018 => OfferCalculator::Errors::NoManipulatedImportFeesFound,
      3001 => OfferCalculator::Errors::MissingTruckingData,
      3002 => OfferCalculator::Errors::LoadMeterageExceeded,
      3003 => OfferCalculator::Errors::TruckingRateNotFound,
      6001 => OfferCalculator::Errors::OfferBuilder,
      6002 => OfferCalculator::Errors::NoValidOffers
    }.freeze

    def self.from_code(code:)
      CODE_LOOKUP[code] || OfferCalculator::Errors::Failure
    end
  end
end
