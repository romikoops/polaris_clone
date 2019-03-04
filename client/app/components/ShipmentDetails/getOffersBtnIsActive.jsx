export function noDangerousGoodsCondition (state) {
  return (
    state.noDangerousGoodsConfirmed ||
    state.cargoItems.some(cargoItem => cargoItem.dangerous_goods) ||
    state.containers.some(container => container.dangerous_goods)
  )
}

export function stackableGoodsCondition (state) {
  return state.stackableGoodsConfirmed || !state.aggregated
}

export default function getOffersBtnIsActive (state) {
  return noDangerousGoodsCondition(state) && stackableGoodsCondition(state) && !state.excessWeightText
}
