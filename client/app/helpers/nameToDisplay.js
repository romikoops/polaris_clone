import { capitalize } from './stringTools'
import { cargoClassOptions } from '../constants'

export default function nameToDisplay (str) {
  const conversionTable = {
    consignee: 'receiver',
    shipper: 'sender',
    lcl: 'Cargo Item',
    chassis: 'Chassis',
    side_lifter: 'Side Lifter'
  }
  cargoClassOptions.forEach((cc) => {
    conversionTable[cc.value] = cc.label
  })
  const inputIsCapitalized = capitalize(str) === str
  const convertedStr = inputIsCapitalized
    ? capitalize(conversionTable[str.toLowerCase()] || str)
    : conversionTable[str] || str

  return convertedStr
}
