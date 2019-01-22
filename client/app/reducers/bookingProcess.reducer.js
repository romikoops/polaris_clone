const initialState = {
  shipment: {
    aggregatedCargo: false,
    onCarriage: false,
    preCarriage: false,
    origin: {},
    destination: {},

    cargoUnits: [],

    trucking: {
      preCarriage: {
        truckType: ''
      },
      onCarriage: {
        truckType: ''
      }
    }
  },
  // These keys should store only page specific auxiliary data
  ChooseShipment: {},
  ShipmentDetails: {},
  ChooseOffer: {},
  BookingDetails: {
    modals: {
      dangerousGoodsInfo: false,
      nonStackable: false,
      noDangerousGoods: false,
      maxDimensions: false
    }
  },
  BookingConfirmation: {}
}

function getUpdatedCargoUnits (state, { index, prop, newValue }) {
  const updatedCargoUnits = [...state.shipment.cargoUnits]

  updatedCargoUnits[index] = {
    ...updatedCargoUnits[index],
    [prop]: newValue
  }

  return updatedCargoUnits
}

export default function bookingProcess (state = initialState, action) {
  switch (action.type) {
    case 'RESET_BP_STORE':
      return { ...initialState }
    case 'UPDATE_BP_SHIPMENT':
      return {
        ...state,
        shipment: {
          ...state.shipment,
          ...action.payload
        }
      }
    case 'UPDATE_BP_MODALS':
      return {
        ...state,
        BookingDetails: {
          ...state.BookingDetails,
          modals: {
            [action.payload]: !state.BookingDetails.modals[action.payload]
          }
        }
      }
    case 'UPDATE_CARGO_UNIT':
      return {
        ...state,
        shipment: {
          ...state.shipment,
          cargoUnits: getUpdatedCargoUnits(state, action.payload)
        }
      }
    case 'ADD_CARGO_UNIT':
      return {
        ...state,
        shipment: {
          ...state.shipment,
          cargoUnits: [
            ...state.shipment.cargoUnits,
            action.payload
          ]
        }
      }
    case 'DELETE_CARGO_UNIT': {
      const cargoUnits = [...state.shipment.cargoUnits]
      cargoUnits.splice(action.payload, 1)

      return {
        ...state,
        shipment: {
          ...state.shipment,
          cargoUnits
        }
      }
    }
    case 'UPDATE_PAGE_DATA':
      return {
        ...state,
        [action.page]: {
          ...state[action.page],
          ...action.payload
        }
      }
    case 'UPDATE_AVAILABLE_MOTS':
      return {
        ...state,
        availableMots: action.payload
      }
    default:
      return state
  }
}
