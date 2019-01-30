let counter = -1
module.exports = {
  v4: () => {
    counter += 1

    return `UUID_MOCK_KEY_${counter}`
  }
}
