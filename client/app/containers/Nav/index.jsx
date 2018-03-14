import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import PropTypes from '../../prop-types'
// import { moment } from '../../constants'
import styles from './index.scss'
// import Loading from '../../components/Loading/Loading'
import { appActions } from '../../actions'
import { capitalize, gradientTextGenerator, history } from '../../helpers'

class NavBar extends Component {
  static goBack () {
    history.goBack()
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
  cellSwitchAdmin (categories) {
    const { admin } = this.props
    switch (categories[1]) {
      case 'clients':
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(admin.client.client.first_name)}  ${capitalize(admin.client.client.last_name)}`}
          </div>
        )
      // eslint-disable-next-line no-case-declarations
      case 'shipments':
        const name =
          admin.shipment && admin.shipment.shipment
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
      case 'hubs':
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${admin.hub.hub.name}`}
          </div>
        )
      case 'routes':
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {`${capitalize(admin.itinerary.itinerary.name)}`}
          </div>
        )
<<<<<<< HEAD
        // eslint-disable-next-line no-case-declarations
=======
      // eslint-disable-next-line no-case-declarations
>>>>>>> cd521d4a1c48b7f8c413cf05b649c571f1225009
      case 'pricings':
        if (categories[2] === 'routes') {
          const routeName =
            admin.itineraryPricings && admin.itineraryPricings.itinerary
              ? admin.itineraryPricings.itinerary.name
              : categories[categories.length - 1]
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
        const clientName =
          admin.clientPricings && admin.clientPricings.client
            ? `${capitalize(admin.clientPricings.client.first_name)}  ${capitalize(admin.clientPricings.client.last_name)}`
            : categories[categories.length - 1]
        return (
          <div
            className={`${styles.nav_cell} flex-none layout-row layout-align-center-center pointy`}
          >
            {' '}
            {clientName}
          </div>
        )
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
      // eslint-disable-next-line no-case-declarations
      case 'shipments':
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
            {`${capitalize(users.clientPricings.client.first_name)}  ${capitalize(users.clientPricings.client.last_name)}`}
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
      if (i <= index) {
        url += `/${c}`
      }
    })
    appDispatch.goTo(url)
  }
  goToDashboard (pathPieces) {
    const { appDispatch } = this.props
    if (pathPieces[0] === 'admin') {
      appDispatch.goTo('/admin/dashboard')
    } else {
      appDispatch.goTo('/account/dashboard')
    }
  }

  render () {
    const { location, theme } = this.props
    const iconStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const pathPieces = location.pathname.split('/')
    pathPieces.splice(0, 1)
    const lastIndex =
      pathPieces.indexOf('pricings') > 0 || pathPieces.indexOf('shipments') > 0 ? 3 : 2
    const breadcrumbs = []
    breadcrumbs.push(<div
      className={`${styles.home_btn} flex-none layout-row layout-align-center-center pointy`}
      onClick={() => this.goToDashboard(pathPieces)}
    >
      {' '}
      <i className="fa fa-home clip" style={iconStyle} />{' '}
    </div>)
    pathPieces.forEach((br, i) => {
      if (br !== 'view') {
        breadcrumbs.push(<div className="flex-none layout-row layout-align-center-center pointy">
          {' '}
          <i className="fa fa-angle-double-right clip" style={iconStyle} />{' '}
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
          className={`${styles.nav_cell} flex-none layout-row layout-align-center-center`}
          onClick={() => NavBar.goBack()}
        >
          <i className="flex-none fa fa-arrow-left" />
          <div className="flex-5" />
          <p className="flex-none">Back</p>
        </div>
      </div>
    )
  }
}

NavBar.propTypes = {
  theme: PropTypes.theme,
  location: PropTypes.objectOf(PropTypes.any),
  users: PropTypes.objectOf(PropTypes.any),
  admin: PropTypes.objectOf(PropTypes.any),
  appDispatch: PropTypes.shape({
    getDashboard: PropTypes.func
  }).isRequired
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
  const { users, admin, tenant } = state
  const { theme } = tenant.data
  return {
    users,
    tenant,
    admin,
    theme
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(NavBar))
