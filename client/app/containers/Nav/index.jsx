import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withNamespaces } from 'react-i18next'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { get } from 'lodash'
import styles from './index.scss'
import { appActions } from '../../actions'
import { capitalize, gradientTextGenerator, history } from '../../helpers'

class NavBar extends Component {
  static goBack () {
    history.goBack()
  }

  static goForward () {
    history.go(1)
  }

  constructor (props) {
    super(props)
    this.state = {}
  }

  finalCell (crumbs) {
    switch (crumbs[0]) {
      case 'admin':
        return this.cellSwitchAdmin(crumbs)
      case 'account':
        return this.cellSwitchUser(crumbs)

      default:
        return ''
    }
  }

  extractClientsData (crumbs) {
    const { clients, t } = this.props
    if (crumbs.length < 4) {
      if (['groupcreator', 'margincreator', 'companycreator'].includes(crumbs[crumbs.length - 1])) {
        return t(`admin:${crumbs[crumbs.length - 1]}`)
      }

      return capitalize(crumbs[crumbs.length - 1])
    }

    switch (crumbs[2]) {
      case 'groups':
        return get(clients, ['group', 'name'], '')
      case 'companies':
        return get(clients, ['company', 'data', 'name'], '')
      case 'client':
        return `${get(clients, ['client', 'clientData', 'first_name'], '')} 
        ${get(clients, ['client', 'clientData', 'last_name'], '')}`

      default:
        return ''
    }
  }

  cellSwitchAdmin (categories) {
    const { admin } = this.props

    switch (categories[1]) {
      case 'clients': {
        const clientName1 = this.extractClientsData(categories)

        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${clientName1}`}
          </div>
        )
      }
      case 'shipments': {
        const name =
          admin.shipment && admin.shipment.shipment && admin.shipment.shipment.imc_reference
            ? admin.shipment.shipment.imc_reference
            : categories[categories.length - 1]

        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(name)}`}
          </div>
        )
      }
      case 'schedules': {
        const scheduleName =
          admin.itinerarySchedules &&
          admin.itinerarySchedules.itinerary &&
          admin.itinerarySchedules.itinerary.name
            ? admin.itinerarySchedules.itinerary.name
            : categories[categories.length - 1]

        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(scheduleName)}`}
          </div>
        )
      }
      case 'hubs':
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(categories[categories.length - 1] === 'hubs'
              ? categories[categories.length - 1] : get(admin, ['hub', 'hub', 'name'], ''))}`}
          </div>
        )
      case 'trucking':
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(categories[categories.length - 1] === 'trucking'
              ? categories[categories.length - 1] : get(admin, ['truckingDetail', 'hub', 'name'], ''))}`}
          </div>
        )
      case 'routes':
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(get(admin, ['itinerary', 'itinerary', 'name'], categories[categories.length - 1]))}`}
          </div>
        )
      case 'pricings': {
        if (categories[2] === 'routes') {
          const id = categories[categories.length - 1]
          const routeName = get(admin, ['pricings', 'show', id, 'itinerary', 'name'], id)

          return (
            <div
              className={`${
                styles.nav_cell
              } flex-none layout-row layout-align-center-center pointy`}
            >
              {' '}
              {`${routeName}`}
            </div>
          )
        }
        if (categories[2] === 'trucking') {
          return (
            <div
              className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
            >
              {' '}
              {`${admin.truckingDetail.hub ? admin.truckingDetail.hub.name : ''}`}
            </div>
          )
        }
        const clientName =
          admin.clientPricings && admin.clientPricings.client
            ? `${capitalize(admin.clientPricings.client.first_name)}  ${capitalize(admin.clientPricings.client.last_name)}`
            : capitalize(categories[categories.length - 1])

        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {clientName}
          </div>
        )
      }
      default:
        return ''
    }
  }

  cellSwitchUser (categories) {
    const { users } = this.props
    switch (categories[1]) {
      case 'client':
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(users.client.client.first_name)}  ${capitalize(users.client.client.last_name)}`}
          </div>
        )
      case 'shipments': {
        const name =
          users.shipment && users.shipment.shipment
            ? users.shipment.shipment.imc_reference
            : categories[categories.length - 1]

        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(name)}`}
          </div>
        )
      }
      case 'hubs':
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${users.hub.hub.name}`}
          </div>
        )
      case 'routes':
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(users.itinerary.itinerary.name)}`}
          </div>
        )
      case 'pricings':
        if (categories[2] === 'routes') {
          return (
            <div
              className={`${
                styles.nav_cell
              } flex-none layout-row layout-align-center-center pointy`}
            >
              {' '}
              {`${users.itineraryPricings.itinerary.name}`}
            </div>
          )
        }

        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {/* {`${capitalize(users.clientPricings.client.first_name)}  ${capitalize(users.clientPricings.client.last_name)}`} */}
          </div>
        )

      default:
        return ''
    }
  }

  navLink (crumbs, index) {
    const { appDispatch } = this.props
    let url = ''
    crumbs.forEach((c, i) => {
      if (i <= index && c !== 'trucking') {
        url += `/${c}`
      }
    })
    appDispatch.goTo(url)
  }

  goToDashboard (pathPieces) {
    const { appDispatch } = this.props
    if (pathPieces[0] === 'admin') {
      appDispatch.goTo('/admin/dashboard')
    } else if (pathPieces[2] === 'trucking') {
      appDispatch.goTo('/admin/pricings')
    } else {
      appDispatch.goTo('/account')
    }
  }

  render () {
    const { location, theme } = this.props
    const iconStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { background: 'black' }
    const pathPieces = location.pathname.split('/')
    pathPieces.splice(0, 1)
    const lastIndex = pathPieces.length - 1
    const breadcrumbs = []
    breadcrumbs.push(<div
      className={`${styles.home_btn} flex-none layout-row layout-align-center-center pointy`}
      onClick={() => this.goToDashboard(pathPieces)}
    >
      {' '}
      <i className="fa fa-home clip" style={iconStyle} />
      {' '}
    </div>)
    pathPieces.forEach((br, i) => {
      if (br !== 'view' && i > 0) {
        breadcrumbs.push(<div className="flex-none layout-row layout-align-center-center pointy">
          {' '}
          <i className="fa fa-angle-double-right clip" style={iconStyle} />
          {' '}
        </div>)
        if (i < lastIndex) {
          breadcrumbs.push(<div
            className={`${
              styles.nav_cell
            } flex-none layout-row layout-align-center-center pointy`}
            onClick={() => this.navLink(pathPieces, i)}
          >
            {' '}
            {capitalize(br)}
          </div>)
        } else {
          breadcrumbs.push(this.finalCell(pathPieces))
        }
      }
    })

    return (
      <div className={`${styles.nav_bar} flex-100 layout-row layout-align-space-between-center`}>
        <div className="flex layout-row layout-align-start-center">{breadcrumbs}</div>
        <div
          className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          onClick={() => NavBar.goBack()}
        >
          <i className="flex-none fa fa-chevron-left" />
          <p className="flex-none center" style={{ paddingLeft: '10px' }}>
            Back
          </p>
        </div>
        <div
          className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          onClick={() => NavBar.goForward()}
        >
          <p className="flex-none center" style={{ paddingRight: '10px' }}>
            Forward
          </p>
          <i className="flex-none fa fa-chevron-right" />
        </div>
      </div>
    )
  }
}

NavBar.defaultProps = {
  theme: null,
  location: {},
  users: {},
  admin: {}
}

function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}
function mapStateToProps (state) {
  const {
    users, admin, app, clients
  } = state
  const { tenant } = app
  const { theme } = tenant

  return {
    users,
    tenant,
    admin,
    theme,
    clients
  }
}

export default withNamespaces('admin')(withRouter(connect(mapStateToProps, mapDispatchToProps)(NavBar)))
