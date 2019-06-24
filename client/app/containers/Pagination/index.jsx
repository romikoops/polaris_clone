import React from 'react'
import PageNavigation from './PageNavigation'
import PageSearchBar from './PageSearchBar'
import { responsive, filters, debounce } from '../../helpers'

class Pagination extends React.PureComponent {
  constructor (props) {
    super(props)

    this.state = {
      page: 1,
      query: ''
    }

    this.getPaginatedItems = this.getPaginatedItems.bind(this)
    this.getNumPages = this.getNumPages.bind(this)
    this.getPerPage = this.getPerPage.bind(this)
    this.nextPage = this.nextPage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.handlePage = this.handlePage.bind(this)
    this.handleSearch = this.handleSearch.bind(this)
    this.handleResize = this.handleResize.bind(this)

    window.addEventListener('resize', this.handleResize)
  }

  componentDidMount () {
    if (this.props.items.length == 0 && this.state.query == '') {
      this.handleRemoteChange()
    }
  }

  componentWillReceiveProps (nextProps) {
    this.setState(prevState => (
      prevState.page > this.getNumPages(nextProps) ? { page: 1 } : {}
    ))
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.handleResize)
  }

  getPaginatedItems () {
    const { items, remote, searchable } = this.props
    const { query } = this.state

    if (remote) return items
    if (searchable && query !== '') {
      return this.localSearch()
    }

    return this.pageLimitedResults(items)
  }

  getNumPages (props) {
    const { items, numPages } = props || this.props

    if (typeof numPages === 'number') return numPages
    if (typeof numPages === 'string') return +numPages

    return Math.ceil(items.length / this.getPerPage())
  }

  getPerPage () {
    const { perPage } = this.props

    if (typeof perPage === 'number') return perPage
    if (typeof perPage === 'string') return +perPage

    return responsive.matchBreakpoint(perPage)
  }

  handleRemoteChange () {
    const { handleChange } = this.props
    const { query } = this.state
    const perPage = this.getPerPage()

    const { page } = this.state

    handleChange({ page, perPage, query })
  }

  handleSearch (event) {
    const { remote } = this.props
    debounce(
      this.setState({ query: event.target.value }, () => {
        if (remote) {
          this.handleRemoteChange()
        } else {
          this.localSearch()
        }
      })
    )
  }

  localSearch () {
    const { items, queryTerms } = this.props
    const { query } = this.state

    if (query === '') {
      return this.pageLimitedResults(items)
    }
    const filteredContacts = filters.handleSearchChange(
      query,
      queryTerms,
      items
    )

    return this.pageLimitedResults(filteredContacts)
  }

  pageLimitedResults (items) {
    const perPage = this.getPerPage()

    const { page } = this.state
    const sliceStartIndex = (page - 1) * perPage
    const sliceEndIndex = page * perPage

    return items.slice(sliceStartIndex, sliceEndIndex)
  }

  nextPage () {
    this.handlePage(1)
  }

  prevPage () {
    this.handlePage(-1)
  }

  handlePage (delta) {
    this.setState(prevState => ({ page: prevState.page + (1 * delta) }), () => {
      if (this.props.remote) {
        this.handleRemoteChange()
      }
    })
  }

  handleResize (e) {
    const prevBreakpoint = responsive.breakpoints.find(breakpoint => breakpoint > this.width)
    const currBreakpoint = responsive.breakpoints.find(breakpoint => breakpoint > e.target.innerWidth)
    if (prevBreakpoint !== currBreakpoint) this.forceUpdate()

    this.width = e.target.innerWidth
  }

  render () {
    const { page } = this.state
    const numPages = this.getNumPages()
    const childProps = {
      page,
      numPages,
      nextPage: +page < numPages ? this.nextPage : null,
      prevPage: +page > 1 ? this.prevPage : null
    }

    const children = this.props.children({ ...childProps, items: this.getPaginatedItems() })

    const components = []
    if (this.props.searchable) {
      components.push(<PageSearchBar t={this.props.t} handleSearch={this.handleSearch} />)
    }
    components.push(children)
    if (this.props.searchable) {
      components.push(<PageNavigation {...childProps} />)
    }

    return components
  }
}

Pagination.defaultProps = {
  perPage: 6,
  items: [],
  pageNavigation: true
}

export default Pagination
