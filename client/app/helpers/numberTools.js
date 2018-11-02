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

  return num.toLocaleString('en', {
    minimumFractionDigits: decimals || 0,
    maximumFractionDigits: decimals || 0
  })
}

export function priceSpacing (value) {
  const localeString = numberSpacing(value, 2)
  const [priceUnits, priceCents] = localeString.split('.')

  return { priceUnits, priceCents }
}
