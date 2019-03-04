export default function addressFieldsAreValid (addressFieldsObj, requiresFullAddress) {
  if (requiresFullAddress) {
    return Object.values(addressFieldsObj).every(value => value)
  } else {
    const notRequiredKeys = ['street', 'number']
    return Object.keys(addressFieldsObj)
      .filter(key => !notRequiredKeys.includes(key))
      .every(key => addressFieldsObj[key])
  }
  
}
