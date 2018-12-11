import React from 'react'
import PageNavigation from './PageNavigation'
import { responsive } from '../../helpers'

class Pagination extends React.PureComponent {
  constructor (props) {
    super(props)

    this.state = { page: 1 }

    this.getPaginatedItems = this.getPaginatedItems.bind(this)
    this.getNumPages = this.getNumPages.bind(this)
    this.getPerPage = this.getPerPage.bind(this)
    this.nextPage = this.nextPage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.handlePage = this.handlePage.bind(this)
    this.handleResize = this.handleResize.bind(this)

    window.addEventListener('resize', this.handleResize)
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
    const { items } = this.props
    const perPage = this.getPerPage()

    const { page } = this.state

    const sliceStartIndex = (page - 1) * perPage
    const sliceEndIndex = page * perPage

    return items.slice(sliceStartIndex, sliceEndIndex)
  }

  getNumPages (props) {
    const { items } = props || this.props

    return Math.ceil(items.length / this.getPerPage())
  }

  getPerPage () {
    const { perPage } = this.props

    if (typeof perPage === 'number') return perPage
    if (typeof perPage === 'string') return +perPage

    return responsive.matchBreakpoint(perPage)
  }

  nextPage () {
    this.handlePage(1)
  }

  prevPage () {
    this.handlePage(-1)
  }

  handlePage (delta) {
    this.setState(prevState => ({ page: prevState.page + (1 * delta) }))
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

    if (!this.props.pageNavigation) return children

    return [children, <PageNavigation {...childProps} />]
  }
}

Pagination.defaultProps = {
  perPage: 6,
  items: [],
  pageNavigation: true
}

export default Pagination
