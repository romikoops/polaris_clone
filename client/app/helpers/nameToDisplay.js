import { capitalize } from './stringTools'

export default function nameToDisplay (str) {
  const converstionTable = {
    consignee: 'receiver',
    shipper: 'sender'
  }
  const inputIsCapitalized = capitalize(str) === str
  const convertedStr = inputIsCapitalized
    ? capitalize(converstionTable[str.toLowerCase()] || str)
    : converstionTable[str] || str

  return convertedStr
}
