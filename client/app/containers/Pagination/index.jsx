import React from 'react'
import PropTypes from '../../prop-types'
import PageNavigation from './PageNavigation'

class Pagination extends React.PureComponent {
  constructor (props) {
    super(props)

    this.state = { page: 1 }

    this.nextPage = this.nextPage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.handlePage = this.handlePage.bind(this)
  }

  componentWillReceiveProps (nextProps, nextState) {
    this.setState(prevState => (
      nextState.page > this.getNumPages(nextProps) ? { page: 1 } : {}
    ))
  }

  getPaginatedItems () {
    const { items, perPage } = this.props

    const { page } = this.state

    const sliceStartIndex = (page - 1) * perPage
    const sliceEndIndex = page * perPage

    return items.slice(sliceStartIndex, sliceEndIndex)
  }

  getNumPages (props) {
    const { perPage, items } = props || this.props

    return Math.ceil(items.length / perPage)
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

  render () {
    const { page } = this.state
    const childProps = {
      page,
      numPages: this.getNumPages(),
      nextPage: this.nextPage,
      prevPage: this.prevPage
    }

    return [
      this.props.children({ ...childProps, items: this.getPaginatedItems() }),
      <PageNavigation {...childProps} />
    ]
  }
}

Pagination.propTypes = {
  perPage: PropTypes.number,
  paginationDispatch: PropTypes.func.isRequired,
  id: PropTypes.string.isRequired,
  metaData: PropTypes.objectOf(PropTypes.any).isRequired,
  children: PropTypes.node.isRequired,
  items: PropTypes.arrayOf(PropTypes.any)
}

Pagination.defaultProps = {
  perPage: 6,
  items: []
}

export default Pagination
