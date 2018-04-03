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
import { AdminHubFees } from './Hub/Fees'
import { AdminCustomsSetter } from './Customs/Setter'

export class AdminHubView extends Component {
  constructor (props) {
    super(props)
    this.state = {
      currentFeeLoadType: { value: 'lcl', label: 'Lcl' },
      currentCustomsLoadType: { value: 'lcl', label: 'Lcl' },
      editedHub: { data: {}, location: {} }
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
      this.filterChargesByLoadType({ value: 'lcl', label: 'Lcl' }, 'fees')
    }
    if (!this.state.currentCustoms && this.props.hubData && this.props.hubData.customs) {
      this.filterChargesByLoadType({ value: 'lcl', label: 'Lcl' }, 'customs')
    }
  }
  componentWillReceiveProps (nextProps) {
    if (!this.state.editedHub.data.name) {
      this.setState({
        editedHub: { data: nextProps.hubData.hub, location: nextProps.hubData.location }
      })
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
  toggleEdit () {
    const { editing } = this.state
    if (!editing) {
      this.setState({
        editing: true
      })
    } else {
      this.setState({ editing: false })
    }
  }
  handleEdit (e) {
    const { name, value } = e.target
    const nameKeys = name.split('-')
    this.setState({
      editedHub: {
        ...this.state.editedHub,
        [nameKeys[0]]: {
          ...this.state.editedHub[nameKeys[0]],
          [nameKeys[1]]: value
        }
      }
    })
  }
  saveEdit () {
    const { adminActions, hubData } = this.props
    const { editedHub } = this.state
    adminActions.editHub(hubData.hub.id, editedHub)
  }
  render () {
    const {
      theme, hubData, hubs, hubHash, adminActions
    } = this.props
    const {
      currentCustomsLoadType,
      currentFeeLoadType,
      currentFee,
      currentCustoms,
      editing,
      editedHub
    } = this.state
    if (!hubData) {
      return ''
    }

    const {
      hub, relatedHubs, routes, schedules, location
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
      <div className={`${styles.action_btn} flex-none layout-row`}>
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
    const editBtn = (
      <div className={`${styles.action_btn} flex-none layout-row`}>
        <RoundButton
          theme={theme}
          size="small"
          text="Edit"
          active
          handleNext={() => this.toggleEdit()}
          iconClass="fa-pencil"
        />
      </div>
    )
    const deactivate = (
      <div className={`${styles.action_btn} flex-none layout-row`}>
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
      <div className={`${styles.action_btn} flex-none layout-row`}>
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
    const editBox = (
      <div className="flex-40 layout-row layout-align-start-center layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center input_box">
          <input
            type="text"
            name="data-name"
            onChange={e => this.handleEdit(e)}
            value={editedHub.data.name}
          />
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <div className="flex-100 layout-row layout-align-space-between-center input_box">
            <input
              type="text"
              className="flex-33"
              name="location-street_number"
              placeholder="Street Number"
              onChange={e => this.handleEdit(e)}
              value={editedHub.location.street_number}
            />
            <input
              type="text"
              className="flex-66"
              name="location-street"
              placeholder="Street"
              onChange={e => this.handleEdit(e)}
              value={editedHub.location.street}
            />
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center input_box_full">
            <input
              type="text"
              className="flex-100"
              name="location-city"
              placeholder="City"
              onChange={e => this.handleEdit(e)}
              value={editedHub.location.city}
            />
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center input_box_full">
            <input
              type="text"
              className="flex-100"
              name="location-zip_code"
              placeholder="Zipcode"
              onChange={e => this.handleEdit(e)}
              value={editedHub.location.zip_code}
            />
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center input_box_full">
            <input
              type="text"
              className="flex-100"
              placeholder="Country"
              name="location-country"
              onChange={e => this.handleEdit(e)}
              value={editedHub.location.country}
            />
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-50 layout-row layout-align-start-center">
            <input
              type="text"
              className="flex-100"
              placeholder="Latitude"
              name="location-latitude"
              onChange={e => this.handleEdit(e)}
              value={editedHub.location.latitude}
            />
          </div>
          <div className="flex-100 layout-row layout-align-start-center">
            <input
              type="text"
              className="flex-100"
              placeholder="Longitude"
              name="location-longitude"
              onChange={e => this.handleEdit(e)}
              value={editedHub.location.longitude}
            />
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-end-center">
          <div className={`${styles.action_btn} flex-none layout-row`}>
            <RoundButton
              theme={theme}
              size="small"
              text="Save"
              handleNext={() => this.saveEdit()}
              iconClass="fa-floppy-o"
            />
          </div>
        </div>
      </div>
    )
    const detailsBox = (
      <div className="flex-40 layout-row layout-align-start-center layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none"> {hub.name}</p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <address className="flex-none">
            {`${location.street_number} ${location.street}`} <br />
            {location.city} <br />
            {location.zip_code} <br />
            {location.country} <br />
          </address>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-50 layout-row layout-align-start-center">
            <p className="flex-none">{`Latitude ${location.latitude}`} </p>
          </div>
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-none"> {`Longitude: ${location.longitude}`} </p>
          </div>
        </div>
      </div>
    )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {hub.name}
          </p>
        </div>
        <div className="flex-100 layout-row layout-align-space-between-start">
          {editing ? editBox : detailsBox}

          <div className="
            flex-20
            layout-column
            layout-wrap
            layout-align-space-between-end
            height_100"
          >
            {hub.hub_status === 'active' ? deactivate : activate}
            {editBtn}
            {deleteBtn}
          </div>
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
    customs: PropTypes.array,
    location: PropTypes.objectOf(PropTypes.any)
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
