import React, { Component } from 'react'
import { v4 } from 'uuid'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import { AdminClientTile } from '../'
import { Tooltip } from '../../Tooltip/Tooltip'

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
      // seeAll,
      placeholder,
      tooltip,
      showTooltip,
      icon,
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
          flexClasses="flex-30 flex-md-45 flex-gt-lg-15"
        />))
    }
    // const viewType = (clientsArr.length > 3) ? (
    //   <div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
    //     <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
    //       {clientsArr}
    //     </div>
    //   </div>
    // ) : (
    //   <div className="layout-row flex-100 layout-align-start-center ">
    //     <div className="layout-row flex-none layout-align-start-center layout-wrap">
    //       {clientsArr}
    //     </div>
    //   </div>
    // )
    const viewType = (<div className="layout-row flex-100 layout-align-start-center ">
      <div className="layout-row flex-none layout-align-space-around-center layout-wrap">
        {clientsArr}
      </div>
    </div>)

    return (
      <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.searchable}`}>
        <div className={`serchables flex-100 layout-row layout-align-space-between-center ${styles.searchable_header}`}>
          <div className="flex-60 layout-row layout-align-start-center">
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div className="flex-none layout-row layout-align-start-center">
                {/* <div className="flex-none" >
                  <TextHeading theme={theme} size={1} text={title || 'Clients'} />
                </div> */}
                { icon ? <Tooltip theme={theme} icon={icon} toolText={tooltip} /> : '' }
              </div>
            </div>
          </div>
          { !hideFilters
            ? <div className="input_box_full flex-40 layout-row layout-align-start-center">
              <input
                type="text"
                name="search"
                placeholder={placeholder || 'Search clients'}
                onChange={this.handleSearchChange}
              />
            </div> : '' }
        </div>
        <div className="flex-100 layout-row layout-align-center layout-align-space-between">
          {viewType}
        </div>
        {/* {seeAll !== false ? (
          <div className="flex-100 layout-row layout-align-end-center">
            <div
              className="flex-none layout-row layout-align-center-center pointy"
              onClick={this.seeAll}
            >
              <p className="flex-none">See all</p>
            </div>
          </div>
        ) : (
          ''
        )} */}
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
  icon: PropTypes.string,
  tooltip: PropTypes.string,
  hideFilters: PropTypes.bool

}

AdminSearchableClients.defaultProps = {
  handleClick: null,
  seeAll: null,
  theme: null,
  showTooltip: false,
  icon: '',
  tooltip: '',
  placeholder: '',
  adminDispatch: null,
  hideFilters: false
}

export default AdminSearchableClients
