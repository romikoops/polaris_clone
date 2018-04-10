export default function getOffersBtnIsActive (state) {
  const dangerousGoodsCondition = (
    state.noDangerousGoodsConfirmed ||
    state.cargoItems.some(cargoItem => cargoItem.dangerous_goods) ||
    state.containers.some(container => container.dangerous_goods)
  )
  const stackeableGoodsCondition = state.stackeableGoodsConfirmed || !state.aggregated

  return dangerousGoodsCondition && stackeableGoodsCondition
}
