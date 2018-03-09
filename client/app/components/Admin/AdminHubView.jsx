import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { AdminLayoverRow, AdminHubTile } from './'
import { AdminSearchableRoutes } from './AdminSearchables'
import styles from './Admin.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { adminClicked as clickTool, cargoClassOptions } from '../../constants'
import { TextHeading } from '../TextHeading/TextHeading'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import AdminHubFees from './Hub/Fees'
import { AdminCustomsSetter } from './Customs/Setter'

export class AdminHubView extends Component {
  constructor (props) {
    super(props)
    this.state = {
      currentFeeLoadType: { value: 'lcl', label: 'Lcl' },
      currentCustomsLoadType: { value: 'lcl', label: 'Lcl' }
    }
    this.toggleHubActive = this.toggleHubActive.bind(this)
    this.getItineraryFromLayover = this.getItineraryFromLayover.bind(this)
  }
  componentDidMount () {
    const {
      hubData, loading, adminActions, match
    } = this.props
    if (!hubData && !loading) {
      adminActions.getHub(parseInt(match.params.id, 10), false)
    }
    this.props.setView()
    if (!this.state.currentFee && this.props.hubData && this.props.hubData.charges) {
      this.filterChargesByLoadType({ value: 'lcl' }, 'fees')
    }
    if (!this.state.currentFee && this.props.hubData && this.props.hubData.customs) {
      this.filterChargesByLoadType({ value: 'lcl' }, 'customs')
    }
  }
  
  getItineraryFromLayover (id) {
    const { routes } = this.props.hubData
    return routes.filter(x => x.id === id)[0]
  }
  deleteHub () {
    const { hubData, adminActions } = this.props
    const { hub } = hubData
    adminActions.deleteHub(hub.id, true)
  }
  toggleHubActive () {
    const { hubData, adminActions } = this.props
    const { hub } = hubData
    adminActions.activateHub(hub.id)
  }
  filterChargesByLoadType (e, target) {
    if (target === 'customs') {
      const filteredCustoms = this.props.hubData.customs.filter(x => x.load_type === e.value)[0]
      this.setState({
        currentCustoms: filteredCustoms,
        currentCustomsLoadType: e
      })
    } else {
      const filteredCharges = this.props.hubData.charges.filter(x => x.load_type === e.value)[0]
      this.setState({
        currentFee: filteredCharges,
        currentFeeLoadType: e
      })
    }
  }
  render () {
    const {
      theme, hubData, hubs, hubHash, adminActions
    } = this.props
    const {
      currentCustomsLoadType, currentFeeLoadType, currentFee, currentCustoms
    } = this.state
    if (!hubData) {
      return ''
    }

    const {
      hub, relatedHubs, routes, schedules
    } = hubData
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const relHubs = []
    relatedHubs.forEach((hubObj) => {
      if (hubObj.id !== hub.id) {
        relHubs.push(<AdminHubTile
          key={v4()}
          hub={hubHash[hubObj.id]}
          theme={theme}
          handleClick={() => adminActions.getHub(hubObj.id, true)}
          tooltip={clickTool.related}
        />)
      }
    })
    const activate = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Activate"
          active
          handleNext={this.toggleHubActive}
          iconClass="fa-plus"
        />
      </div>
    )
    const deactivate = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Deactivate"
          handleNext={this.toggleHubActive}
          iconClass="fa-ban"
        />
      </div>
    )
    const deleteBtn = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Delete"
          handleNext={() => this.deleteHub()}
          iconClass="fa-trash"
        />
      </div>
    )

    const schedArr = schedules.map((sched) => {
      const tmpItin = this.getItineraryFromLayover(sched.itinerary_id)
      return (
        <AdminLayoverRow key={v4()} schedule={sched} hub={hub} theme={theme} itinerary={tmpItin} />
      )
    })
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {hub.name}
          </p>
          {hub.hub_status === 'active' ? deactivate : activate}
          {deleteBtn}
        </div>

        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Related Hubs</p>
          </div>
          {relHubs}
        </div>
        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
          <div className="flex-50 layout-row layout-align-start-center">
            <TextHeading theme={theme} text="Fees & Charges" size={3} />
          </div>
          <div className="flex-50 layout-row layout-align-end-center">
            <NamedSelect
              className={styles.select}
              options={cargoClassOptions}
              onChange={e => this.filterChargesByLoadType(e, 'fees')}
              value={currentFeeLoadType}
              name="currentFeeLoadType"
            />
          </div>
          <AdminHubFees
            theme={theme}
            charges={currentFee}
            adminDispatch={adminActions}
            loadType={currentFeeLoadType.value}
          />
        </div>
        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
          <div className="flex-50 layout-row layout-align-start-center">
            <TextHeading theme={theme} text="Customs" size={3} />
          </div>
          <div className="flex-50 layout-row layout-align-end-center">
            <NamedSelect
              className={styles.select}
              options={cargoClassOptions}
              onChange={e => this.filterChargesByLoadType(e, 'customs')}
              value={currentCustomsLoadType}
              name="currentCustomsLoadType"
            />
          </div>
          <AdminCustomsSetter
            theme={theme}
            charges={currentCustoms}
            adminDispatch={adminActions}
            loadType={currentCustomsLoadType.value}
          />
        </div>
        <AdminSearchableRoutes
          itineraries={routes}
          theme={theme}
          hubs={hubs}
          adminDispatch={adminActions}
        />
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Schedules </p>
          </div>
          {schedArr}
        </div>
      </div>
    )
  }
}
AdminHubView.propTypes = {
  theme: PropTypes.theme,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  hubs: PropTypes.arrayOf(PropTypes.hub),
  adminActions: PropTypes.shape({
    getHub: PropTypes.func,
    activateHub: PropTypes.func
  }).isRequired,
  hubData: PropTypes.shape({
    hub: PropTypes.hub,
    relatedHubs: PropTypes.arrayOf(PropTypes.hub),
    routes: PropTypes.array,
    schedules: PropTypes.array,
    charges: PropTypes.array,
    customs: PropTypes.array
  }),
  loading: PropTypes.bool,
  match: PropTypes.match.isRequired,
  setView: PropTypes.func
}

AdminHubView.defaultProps = {
  theme: null,
  loading: false,
  hubData: null,
  hubHash: {},
  hubs: [],
  setView: null
}

export default AdminHubView
