const address = {
  country: 'CONTACT_ADDRESS_COUNTRY',
  street_number: 'CONTACT_ADDRESS_STREET_NUMBER',
  city: 'CONTACT_ADDRESS_CITY',
  zip_code: 'CONTACT_ADDRESS_ZIP_CODE'
}
const data = {
  company_name: 'CONTACT_DATA_COMPANY_NAME',
  email: 'CONTACT_DATA_COMPANY_EMAIL',
  phone: 'CONTACT_DATA_COMPANY_PHONE'
}
export const contact = {
  address,
  data,
  email: 'foo@bar.baz',
  phone: '0761452887',
  firstName: 'John',
  lastName: 'Doe',
  companyName: 'CONTACT_COMPANY_NAME'
}

export const firstContact = {
  primary: 2,
  first_name: 'FOO_FIRST_NAME',
  last_name: 'FOO_LAST_NAME',
  email: 'FOO_EMAIL@mehr.de',
  company_name: 'FOO_COMPANY_NAME'
}

export const secondContact = {
  primary: 1,
  first_name: 'BAR_FIRST_NAME',
  last_name: 'BAR_LAST_NAME',
  email: 'BAR_EMAIL@mehr.de',
  company_name: 'BAR_COMPANY_NAME'
}

export const contacts = [
  firstContact,
  secondContact
]
