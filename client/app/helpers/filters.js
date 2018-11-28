import Fuse from 'fuse.js'

function handleSearchChange (query, searchKeys, array) {
  if (!query || query === '') {
    return array
  }
  const search = (keys) => {
    const options = {
      shouldSort: true,
      tokenize: true,
      threshold: 0.4,
      location: 0,
      distance: 50,
      maxPatternLength: 32,
      minMatchCharLength: 2,
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

function sortByAlphabet (array, key) {
  array.sort((a, b) => {
    const nameA = a[key].toUpperCase()
    const nameB = b[key].toUpperCase()

    return nameA.localeCompare(nameB)
  })

  return array
  
}

const filters = {
  handleSearchChange,
  sortByDate,
  sortByAlphabet
}
export default filters
