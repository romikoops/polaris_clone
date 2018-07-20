import Fuse from 'fuse.js'

function handleSearchChange (query, searchKeys, array) {
  if (!query || query === '') {
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

    return fuse.search(query)
  }

  const filteredResults = search(searchKeys)

  return filteredResults
}

function sortByDate (array, key) {
  return array.sort((a, b) => new Date(b[key]) - new Date(a[key]))
}

const filters = {
  handleSearchChange,
  sortByDate
}
export default filters
