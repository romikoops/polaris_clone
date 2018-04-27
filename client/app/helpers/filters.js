import Fuse from 'fuse.js'

function handleSearchChange (event, searchKeys, array) {
  if (event.target.value === '') {
    return array
  }
  const search = (keys) => {
    const options = {
      shouldSort: true,
      tokenize: true,
      threshold: 0.2,
      location: 0,
      distance: 50,
      maxPatternLength: 32,
      minMatchCharLength: 5,
      keys
    }
    const fuse = new Fuse(array, options)
    return fuse.search(event.target.value)
  }

  const filteredResults = search(searchKeys)
  return filteredResults
}

const filters = {
  handleSearchChange
}
export default filters
