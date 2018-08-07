function splitName (fullName) {
  const fullNameArr = fullName.split(' ')
  const hubType = fullNameArr.pop()
  const name = fullNameArr.join(' ')

  return {
    hubType,
    name
  }
}

export default splitName
