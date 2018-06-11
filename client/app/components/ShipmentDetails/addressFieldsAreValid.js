export default function addressFieldsAreValid (addressFieldsObj) {
  return Object.values(addressFieldsObj).every(value => value)
}
