import { capitalize } from './stringTools'

export default function nameToDisplay (str) {
  const converstionTable = {
    consignee: 'receiver',
    shipper: 'sender',
    fcl_20: '20ft Container',
    fcl_40: '40ft Container',
    fcl_40_hq: '40ft HQ Container',
    lcl: 'Cargo Item',
    chassis: 'Chassis',
    side_lifter: 'Side Lifter'
  }
  const inputIsCapitalized = capitalize(str) === str
  const convertedStr = inputIsCapitalized
    ? capitalize(converstionTable[str.toLowerCase()] || str)
    : converstionTable[str] || str

  return convertedStr
}
