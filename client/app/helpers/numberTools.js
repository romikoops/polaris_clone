export function numberSpacing (number, decimals) {
  if (!number && number !== 0) {
    return ''
  }

  let num
  if (typeof number === 'string') {
    num = parseFloat(number)
  } else {
    num = number
  }

  return displaysValue(num.toLocaleString('en', {
    minimumFractionDigits: decimals || 0,
    maximumFractionDigits: decimals || 0
  }), number, decimals)
}

export function priceSpacing (value) {
  const localeString = numberSpacing(value, 2)
  const [priceUnits, priceCents] = localeString.split('.')

  return { priceUnits, priceCents }
}
function displaysValue (value, number, decimals) {
  if (!decimals || parseFloat(number) === 0 || decimals === 3) return value
  const tail = value.substr(-1 * decimals)
  let nullValueString = '' 
  for (let i = 0; i < decimals; i++) {
    nullValueString += '0'
  }

  if (tail === nullValueString && number < 1) {
    return numberSpacing(number, decimals + 1)
  }

  return value
}
