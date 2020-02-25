export function previewPrepare (breakdowns, cargo, key) {
  const feeBreakdowns = extractBreakdowns(breakdowns, cargo, key)
  const originalFee = feeBreakdowns[0]
  const marginBreakdowns = feeBreakdowns.filter((breakdown) => !!breakdown.margin_id && breakdown.operator !== '+')
  const flatMarginBreakdowns = feeBreakdowns.filter((breakdown) => !!breakdown.margin_id && breakdown.operator === '+')
  const finalFee = marginBreakdowns[marginBreakdowns.length - 1]
  const result = {
    original: originalFee.data,
    metadata: originalFee.rate_origin
  }

  if (finalFee) {
    result.final = finalFee.data
  }
  result.margins = marginBreakdowns
  result.flatMargins = flatMarginBreakdowns

  return result
}

export function extractBreakdowns (breakdowns, cargo, key) {
  return breakdowns
    .filter((breakdown) => (cargoEquality(breakdown, key, cargo)))
    .sort((a, b) => (a.order - b.order))
}

export function breakdownExists (breakdowns, cargo, key) {
  return !!breakdowns.find((breakdown) => (cargoEquality(breakdown, key, cargo)))
}

function cargoEquality (breakdown, key, cargo) {
  const isConsoldiatedCargo = !cargo || cargo.id === 'cargo_item'

  return isConsoldiatedCargo ? noCargoEquality(breakdown, key) : withCargoEquality(breakdown, key, cargo.id)
}

export function noCargoEquality (breakdown, key) {
  return breakdown.code === key
}

export function withCargoEquality (breakdown, key, cargoId) {
  return breakdown.code === key && breakdown.cargo_unit_id === cargoId
}
