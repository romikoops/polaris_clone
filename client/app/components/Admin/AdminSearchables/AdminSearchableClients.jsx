import React, { Component } from 'react'
import { v4 } from 'uuid'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import { AdminClientTile } from '../'

export class AdminSearchableClients extends Component {
  constructor (props) {
    super(props)
    this.state = {
      clients: props.clients
    }
    this.handleSearchChange = this.handleSearchChange.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.seeAll = this.seeAll.bind(this)
  }
  componentDidUpdate (prevProps) {
    if (prevProps.clients !== this.props.clients) {
      this.handleSearchChange({ target: { value: '' } })
    }
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
      theme,
      title,
      placeholder,
      tooltip,
      showTooltip,
      hideFilters
    } = this.props

    const { clients } = this.state
    let clientsArr
    if (clients) {
      clientsArr = clients.map(client => (
        <AdminClientTile
          key={v4()}
          client={client}
          theme={theme}
          handleClick={this.handleClick}
          tooltip={tooltip}
          showTooltip={showTooltip}
        />
      ))
    }

    return (
      <div className={`layout-row flex-95 layout-wrap ${styles.searchable}`}>
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
                placeholder={placeholder || 'Search clients'}
                onChange={this.handleSearchChange}
              />
            </div> : '' }
        </div>
        {clientsArr}
      </div>
    )
  }
}
AdminSearchableClients.propTypes = {
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

export default AdminSearchableClients
