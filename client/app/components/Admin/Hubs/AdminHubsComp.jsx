import React, { Component } from 'react'
import { v4 } from 'uuid'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import { adminClicked as clickTip } from '../../../constants'
import Checkbox from '../../Checkbox/Checkbox'
import { capitalize } from '../../../helpers'
import { AdminHubTile } from './AdminHubTile'
import SideOptionsBox from '../SideOptions/SideOptionsBox'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'
import { NamedSelect } from '../../NamedSelect/NamedSelect'
import { adminActions, appActions } from '../../../actions'

export class AdminHubsComp extends Component {
  constructor (props) {
    super(props)
    this.state = {
      searchFilters: {
        hubType: {
        },
        status: {
          active: true,
          inactive: false
        },
        countries: []
      },
      page: 1,
      expander: {}
    }
    this.nextPage = this.nextPage.bind(this)
    this.handleFilters = this.handleFilters.bind(this)
    this.handlePage = this.handlePage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.handleInput = this.handleInput.bind(this)
  }
  componentDidMount () {
    const {
      hubs, adminDispatch, loading, countries, appDispatch, tenant
    } = this.props
    if (tenant && tenant.data) {
      this.setHubTypes()
    }
    if (!hubs && !loading) {
      adminDispatch.getHubs(false)
    }
    if (!countries.length) {
      appDispatch.fetchCountries()
    }
  }

  getHubsFromPage (page, hubType, country, status) {
    const { adminDispatch } = this.props
    adminDispatch.getHubs(false, page, hubType, country, status)
  }
  setHubTypes () {
    const { tenant } = this.props
    const { scope } = tenant.data
    const newTypeObj = {}
    Object.keys(scope.modes_of_transport).forEach((mot) => {
      const boolSum = Object.values(scope.modes_of_transport[mot]).reduce((a, b) => a + b, 0)
      if (boolSum > 0) {
        newTypeObj[mot] = true
      }
    })
    this.setState(prevState => ({
      searchFilters: {
        ...prevState.searchFilters,
        hubType: newTypeObj
      }
    }))
  }
  searchHubsFromPage (text, page, hubType, country, status) {
    const { adminDispatch } = this.props
    adminDispatch.searchHubs(text, page, hubType, country, status)
  }
  fetchCountries () {
    const { appDispatch } = this.props
    appDispatch.fetchCountries()
  }

  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }

  toggleFilterValue (target, key) {
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        [target]: {
          ...this.state.searchFilters[target],
          [key]: !this.state.searchFilters[target][key]
        }
      }
    }, () => this.handleFilters())
  }
  handleInput (selection) {
    const selectValues = selection
    delete selectValues.name

    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        countries: Object.values(selectValues)
      }
    }, () => this.handleFilters())
  }

  handlePage (direction, hubType, country, status) {
    if (!hubType && !country && !status) {
      this.setState((prevState) => {
        const nextPage = prevState.page + (1 * direction)
        this.getHubsFromPage(nextPage > 0 ? nextPage : 1)

        return { page: prevState.page + (1 * direction) }
      }, () => this.handleFilters())
    } else {
      this.handleFilters()
    }
  }
  handleFilters () {
    const { searchFilters } = this.state

    const hubFilterKeys =
      Object.keys(searchFilters.hubType).filter(key => searchFilters.hubType[key])
    const countryKeys =
      searchFilters.countries.map(selection => selection.value)
    const statusFilterKeys =
      Object.keys(searchFilters.status).filter(key => searchFilters.status[key])
    this.setState((prevState) => {
      this.getHubsFromPage(prevState.page, hubFilterKeys, countryKeys, statusFilterKeys)

      return { page: prevState.page }
    })
  }
  nextPage () {
    this.handlePage(1)
  }
  prevPage () {
    this.handlePage(-1)
  }
  doNothing () {
    console.log(this.state.page)
  }

  handleSearchQuery (e) {
    const { value } = e.target
    const { searchFilters } = this.state

    const hubFilterKeys =
      Object.keys(searchFilters.hubType).filter(key => searchFilters.hubType[key])
    const countryKeys =
      searchFilters.countries.map(selection => selection.value)
    const statusFilterKeys =
      Object.keys(searchFilters.status).filter(key => searchFilters.status[key])
    this.setState((prevState) => {
      this.searchHubsFromPage(value, 1, hubFilterKeys, countryKeys, statusFilterKeys)

      return { page: 1 }
    })
  }

  render () {
    const { searchFilters, expander } = this.state
    const {
      theme,
      actionNodes,
      hubs,
      countries,
      numHubPages,
      handleClick
    } = this.props

    if (!this.props.hubs) {
      return ''
    }
    const typeFilters = Object.keys(searchFilters.hubType).map((hubType) => {
      const typeNames = {
        ocean: 'Port', air: 'Airport', rail: 'Railyard', truck: 'Depot'
      }

      return (
        <div className={`${styles.action_section} flex-100 layout-row layout-align-center-center layout-wrap`}>
          <label htmlFor={hubType} className="pointy">
            <p>{typeNames[hubType]}</p>
          </label>
          <Checkbox
            id={hubType}
            onChange={() => this.toggleFilterValue('hubType', hubType)}
            checked={searchFilters.hubType[hubType]}
            theme={theme}
          />
        </div>
      )
    })
    const statusFilters = Object.keys(searchFilters.status).map(status => (
      <div className={`${styles.action_section} flex-100 layout-row layout-align-center-center layout-wrap`}>
        <label htmlFor={status} className="pointy">
          <p>{capitalize(status)}</p>
        </label>

        <Checkbox
          id={status}
          onChange={() => this.toggleFilterValue('status', status)}
          checked={searchFilters.status[status]}
          theme={theme}
        />
      </div>
    ))
    const loadCountries = countries ? countries.map(country => ({
      label: country.name,
      value: country.id
    })) : []

    const namedCountries = (
      <NamedSelect
        className="flex-100 selectors"
        multi
        name="country_select"
        value={searchFilters.countries}
        autoload={false}
        options={loadCountries}
        onChange={e => this.handleInput(e)}
      />
    )

    const hubsArr = hubs.map(hub => (
      <AdminHubTile
        key={v4()}
        hub={hub}
        theme={theme}
        handleClick={handleClick}
        tooltip={clickTip.related}
        showTooltip
      />
    ))

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-space-between-start">
          <div className="layout-row flex-80 flex-md-75 flex-sm-100">
            <div className="layout-row flex-100 layout-align-start-center header_buffer layout-wrap">
              <div className="layout-row flex-95 layout-wrap card_margin_right" style={{ minHeight: '450px' }}>
                {hubsArr}
              </div>

              <div className="flex-95 layout-row layout-align-center-center margin_bottom">
                <div
                  className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${this.state.page === 1 ? styles.disabled : ''}
                    `}
                  onClick={this.state.page > 1 ? this.prevPage : null}
                >
                  <i className="fa fa-chevron-left" />
                  <p>&nbsp;&nbsp;&nbsp;&nbsp;Back</p>
                </div>
                {}
                <p>{this.state.page}</p>
                <div
                  className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${this.state.page < numHubPages ? '' : styles.disabled}
                    `}
                  onClick={this.state.page < numHubPages ? this.nextPage : null}
                >
                  <p>Next&nbsp;&nbsp;&nbsp;&nbsp;</p>
                  <i className="fa fa-chevron-right" />
                </div>
              </div>

            </div>
          </div>
          <div className="flex-20 flex-md-25 hide-sm hide-xs layout-row layout-wrap layout-align-end-end">
            <div className={`${styles.position_fixed_right} flex`}>

              <div className={`${styles.filter_panel} flex layout-row`}>
                <SideOptionsBox
                  header="Filters"
                  flexOptions="flex"
                  content={(
                    <div>
                      <div
                        className="flex-100 layout-row layout-wrap layout-align-center-start input_box_full"
                      >
                        <input
                          type="text"
                          className="flex-100"
                          value={searchFilters.query}
                          placeholder="Search..."
                          onChange={e => this.handleSearchQuery(e)}
                        />
                      </div>
                      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                        <CollapsingBar
                          collapsed={!expander.hubType}
                          theme={theme}
                          handleCollapser={() => this.toggleExpander('hubType')}
                          text="Hub Type"
                          faClass="fa fa-ship"
                          showArrow
                          content={typeFilters}
                        />
                        <CollapsingBar
                          collapsed={!expander.status}
                          theme={theme}
                          handleCollapser={() => this.toggleExpander('status')}
                          text="Status"
                          faClass="fa fa-ship"
                          showArrow
                          content={statusFilters}
                        />
                        <CollapsingBar
                          collapsed={!expander.countries}
                          theme={theme}
                          minHeight="270px"
                          handleCollapser={() => this.toggleExpander('countries')}
                          text="Country"
                          faClass="fa fa-flag"
                          showArrow
                          content={namedCountries}
                        />
                      </div>
                    </div>
                  )}
                />
              </div>
              <div className="flex layout-row margin_bottom">
                {actionNodes}
              </div>
            </div>
          </div>
        </div>
      </div>

    )
  }
}

AdminHubsComp.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  numHubPages: PropTypes.number.isRequired,
  countries: PropTypes.arrayOf(PropTypes.any),
  actionNodes: PropTypes.arrayOf(PropTypes.node),
  handleClick: PropTypes.func,
  tenant: PropTypes.tenant,
  loading: PropTypes.bool,
  appDispatch: PropTypes.shape({
    fetchCountries: PropTypes.func
  }).isRequired,
  adminDispatch: PropTypes.shape({
    getHubs: PropTypes.func,
    saveNewHub: PropTypes.func
  }).isRequired
}

AdminHubsComp.defaultProps = {
  theme: null,
  hubs: [],
  countries: [],
  actionNodes: [],
  handleClick: null,
  tenant: {},
  loading: false
}

function mapStateToProps (state) {
  const {
    authentication, tenant, admin, document, app
  } = state
  const { theme } = tenant.data
  const { user, loggedIn } = authentication
  const {
    clients, hubs, hub, num_hub_pages // eslint-disable-line
  } = admin
  const { countries } = app

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    theme,
    hub,
    numHubPages: num_hub_pages,
    countries,
    clients,
    document
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminHubsComp)
