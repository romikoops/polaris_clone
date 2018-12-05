import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import { AdminClientTile } from '../'

export class AdminSearchableClients extends Component {
  constructor (props) {
    super(props)
    this.state = {
      clients: props.clients,
      page: 1,
      pages: 1,
      perPage: 6
    }
    this.handleSearchChange = this.handleSearchChange.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.seeAll = this.seeAll.bind(this)
    this.nextPage = this.nextPage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.handlePage = this.handlePage.bind(this)
  }
  componentDidMount () {
    this.determinePerPage()
  }
  componentDidUpdate (prevProps) {
    if (prevProps.clients !== this.props.clients) {
      this.handleSearchChange({ target: { value: '' } })
    }
  }
  determinePerPage () {
    const { clients } = this.props
    const width = window.innerWidth
    const newPerPage = width >= 1920 ? 6 : 4
    const pages = Math.ceil(clients.length / newPerPage)
    this.setState({ perPage: newPerPage, clients, pages })
  }
  handleClick (client) {
    const { handleClick, adminDispatch } = this.props
    if (handleClick) {
      handleClick(client)
    } else {
      adminDispatch.getClient(client.id, true)
    }
  }
  seeAll () {
    const { seeAll, adminDispatch } = this.props
    if (seeAll) {
      seeAll()
    } else {
      adminDispatch.goTo('/admin/clients')
    }
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
  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        clients: this.props.clients
      })

      return
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
      const fuse = new Fuse(this.props.clients, options)

      return fuse.search(event.target.value)
    }
    const filteredClients = search(['first_name', 'last_name', 'company_name', 'phone', 'email'])

    this.setState({
      clients: filteredClients
    })
  }
  render () {
    const {
      t,
      theme,
      title,
      placeholder,
      tooltip,
      showTooltip,
      hideFilters
    } = this.props
    const {
      page, pages, perPage, clients
    } = this.state
    let clientsArr
    const startIndex = (page - 1) * perPage
    const endIndex = page * perPage

    if (clients) {
      clientsArr = clients
        .sort((a, b) => b.primary - a.primary)
        .slice(startIndex, endIndex)
        .map(client => (
          <AdminClientTile
            key={v4()}
            client={client}
            theme={theme}
            flexClasses="flex-45 flex-gt-sm-33"
            handleClick={this.handleClick}
            tooltip={tooltip}
            showTooltip={showTooltip}
          />
        ))
    }

    return (
      <div className={`layout-row flex-100 layout-wrap layout-align-start-start ${styles.searchable}`}>
        {title ? (
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div
              className="flex-100 layout-align-start-center greyBg"
            >
              <span><b>{title}</b></span>
            </div>
          </div>
        ) : ''}
        <div className={`searchables flex-100 layout-row layout-align-end-center ${styles.searchable_header}`}>
          { !hideFilters
            ? <div className="input_box_full flex-40 layout-row layout-align-end-center">
              <input
                type="text"
                name="search"
                placeholder={placeholder || t('admin:searchClients')}
                onChange={this.handleSearchChange}
              />
            </div> : '' }
        </div>
        <div className={`flex-100 layout-wrap layout-row layout-align-start-start ${styles.searchable_section}`}>
          {clientsArr}
        </div>
        <div className={`flex-95 layout-row layout-align-center-center ${styles.pagination_buttons}`}>
          <div
            className={`
              flex-15 layout-row layout-align-center-center pointy
              ${styles.navigation_button} ${parseInt(page, 10) === 1 ? styles.disabled : ''}
            `}
            onClick={parseInt(page, 10) > 1 ? this.prevPage : null}
          >
            <i className="fa fa-chevron-left" />
            <p>&nbsp;&nbsp;&nbsp;&nbsp;{t('common:basicBack')}</p>
          </div>
          {}
          <p>{page} / {pages} </p>
          <div
            className={`
              flex-15 layout-row layout-align-center-center pointy
              ${styles.navigation_button} ${parseInt(page, 10) < pages ? '' : styles.disabled}
            `}
            onClick={parseInt(page, 10) < pages ? this.nextPage : null}
          >
            <p>{t('common:next')}&nbsp;&nbsp;&nbsp;&nbsp;</p>
            <i className="fa fa-chevron-right" />
          </div>
        </div>
      </div>
    )
  }
}
AdminSearchableClients.propTypes = {
  t: PropTypes.func.isRequired,
  clients: PropTypes.arrayOf(PropTypes.client).isRequired,
  handleClick: PropTypes.func,
  adminDispatch: PropTypes.shape({
    getClient: PropTypes.func,
    goTo: PropTypes.func
  }),
  seeAll: PropTypes.func,
  placeholder: PropTypes.string,
  theme: PropTypes.theme,
  showTooltip: PropTypes.bool,
  tooltip: PropTypes.string,
  hideFilters: PropTypes.bool,
  title: PropTypes.string
}

AdminSearchableClients.defaultProps = {
  handleClick: null,
  seeAll: null,
  theme: null,
  showTooltip: false,
  tooltip: '',
  placeholder: '',
  adminDispatch: null,
  hideFilters: false,
  title: ''
}

export default withNamespaces(['admin', 'common'])(AdminSearchableClients)
