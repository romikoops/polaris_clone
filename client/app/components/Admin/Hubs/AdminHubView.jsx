import React, { Component } from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import { AdminHubTile } from '../'
import styles from '../Admin.scss'
import { adminClicked as clickTool } from '../../../constants'
import { AdminHubFees } from './Fees'
import AdminPromptConfirm from '../Prompt/Confirm'
import hubStyles from './index.scss'
import '../../../styles/react-toggle.scss'
import { gradientGenerator, gradientTextGenerator, switchIcon, renderHubType, capitalize, gradientBorderGenerator } from '../../../helpers'
import MandatoryChargeBox from './MandatoryChargeBox'
import AlternativeGreyBox from '../../GreyBox/AlternativeGreyBox'
import ItineraryRow from '../Itineraries/ItineraryRow'
import { AdminHubEdit } from './AdminHubEdit'
import { SimpleMap as Map } from '../../Maps/SimpleMap'
import GmapsWrapper from '../../../hocs/GmapsWrapper'

export class AdminHubView extends Component {
  constructor (props) {
    super(props)
    this.state = {
      currentFeeLoadType: { value: 'lcl', label: 'Lcl' },
      editedHub: { data: {}, location: {} },
      mandatoryCharge: {},
      editView: false
    }
    this.toggleHubActive = this.toggleHubActive.bind(this)
    this.getItineraryFromLayover = this.getItineraryFromLayover.bind(this)
  }
  componentDidMount () {
    this.checkAndSetCharges(this.props)
  }
  componentWillReceiveProps (nextProps) {
    if (!this.state.mapWidth) {
      const mapWidth = this.mapElement ? this.mapElement.clientWidth : '1000'
      this.setState({ mapWidth })
    }
    if (!this.state.editedHub.data.name) {
      this.setState({
        editedHub: { data: nextProps.hubData.hub, location: nextProps.hubData.location }
      })
    }
    if (this.props.hubData && nextProps.hubData) {
      if (
        this.props.hubData.charges !== nextProps.hubData.charges ||
        this.props.hubData.customs !== nextProps.hubData.customs
      ) {
        this.checkAndSetCharges(nextProps)
      }
      if (
        !this.state.mandatoryCharge || (nextProps.hubData.mandatoryCharges !== this.state.mandatoryCharge)
      ) {
        const { mandatoryCharges } = nextProps.hubData
        this.setState({ mandatoryCharge: mandatoryCharges })
      }
    }
  }

  getItineraryFromLayover (id) {
    const { routes } = this.props.hubData

    return routes.filter(x => x.id === id)[0]
  }
  toggleHubActive () {
    const { hubData, adminActions } = this.props
    const { hub } = hubData
    adminActions.activateHub(hub.id)
  }
  checkAndSetCharges (props) {
    const {
      hubData, loading, adminActions, match
    } = props
    if (!hubData && !loading) {
      adminActions.getHub(parseInt(match.params.id, 10), false)
    }
    if (!this.state.currentFee && this.props.hubData && this.props.hubData.charges) {
      this.filterChargesByLoadType({ value: 'lcl', label: 'Lcl' }, 'fees')
    }
    if (!this.state.currentCustoms && this.props.hubData && this.props.hubData.customs) {
      this.filterChargesByLoadType({ value: 'lcl', label: 'Lcl' }, 'customs')
    }
  }
  filterChargesByLoadType (e, target) {
    if (target === 'customs') {
      const filteredCustoms = this.props.hubData.customs.filter(x => x.load_type === e.value)[0]
      this.setState({
        currentCustoms: filteredCustoms || {}
      })
    } else {
      const filteredCharges = this.props.hubData.charges.filter(x => x.load_type === e.value)[0]
      this.setState({
        currentFee: filteredCharges || {},
        currentFeeLoadType: e
      })
    }
  }
  deleteHub (id) {
    const { hubData, adminActions } = this.props
    const { hub } = hubData
    adminActions.deleteHub(hub.id, true)
    this.closeConfirm()
  }
  confirmDelete () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }
  saveMandatoryChargeEdit (newMandatoryCharge) {
    const { adminActions, hubData } = this.props
    adminActions.updateHubMandatoryCharges(hubData.hub.id, newMandatoryCharge)
  }

  toggleEdit () {
    const { editView } = this.state
    if (!editView) {
      this.setState({
        editView: true
      })
    } else {
      this.setState({ editView: false })
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
      theme, hubData, hubHash, adminActions
    } = this.props
    const {
      currentFeeLoadType,
      editView,
      confirm,
      mandatoryCharge
    } = this.state
    if (!hubData || !theme) {
      return ''
    }

    const {
      hub, relatedHubs, routes, location, charges, customs
    } = hubData
    if (!hub) {
      return ''
    }
    const { primary, secondary } = theme.colors
    const textStyle = gradientTextGenerator(primary, secondary)
    const borderStyle = gradientBorderGenerator(primary, secondary)
    const gradientBackground = gradientGenerator(primary, secondary)
    const gradientIcon = gradientTextGenerator(primary, secondary)
    // const hubPhoto = { background: hub.photo }
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
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading="Are you sure?"
        text={`This will delete the hub ${hub.name} and all related data`}
        confirm={() => this.deleteHub(hub.id)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const activate = (
      <div
        className={`flex-none layout-row pointy layout-align-center-center ${hubStyles.header_bar_inactive_button}`}
        style={borderStyle}
        onClick={this.toggleHubActive}
      >
        <div className={`flex-none layout-row layout-align-center-center ${hubStyles.inactive_inner}`}>
          <p className="flex-none">
            {capitalize(hub.hub_status)}
          </p>
        </div>

      </div>
    )
    const deactivate = (
      <div
        className={`flex-none layout-row pointy layout-align-center-center ${hubStyles.header_bar_active_button}`}
        style={textStyle}
        onClick={this.toggleHubActive}
      >
        <p className="flex-none">
          {capitalize(hub.hub_status)}
        </p>
      </div>
    )

    const editorModal = (<AdminHubEdit
      hub={hub}
      theme={theme}
      saveHub={this.saveHub}
      adminDispatch={adminActions}
      close={() => this.toggleEdit()}
    />)
    const toggleCSS = `
    .react-toggle--checked .react-toggle-track {
      background: linear-gradient(
        90deg,
        ${theme.colors.brightPrimary} 0%,
        ${theme.colors.primary} 100%
      ) !important;
      border: 0.5px solid rgba(0, 0, 0, 0);
    }
    .react-toggle-track {
      background: linear-gradient(
        90deg,
        ${theme.colors.brightSecondary} 0%,
        ${theme.colors.secondary} 100%
      ) !important;
      border: 0.5px solid rgba(0, 0, 0, 0);
    }
    .react-toggle:hover .react-toggle-track{
      background: rgba(0, 0, 0, 0.5) !important;
    }
  `
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''
    const addressString1 = `${hub.location.street_number || ''} ${hub.location.street || ''}, ${hub.location.zip_code || ''}`
    const addressString2 = `${hub.location.city || ''} ${hub.location.country.name || ''}`
    const mandatoryChargeBox = (<MandatoryChargeBox
      mandatoryCharge={mandatoryCharge}
      theme={theme}
      saveChanges={e => this.saveMandatoryChargeEdit(e)}
    />)
    const itinerariesBox = routes.map(r =>
      (<ItineraryRow
        itinerary={r}
        theme={theme}
        adminDispatch={adminActions}
      />))

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        {editView ? editorModal : '' }
        <div
          className={`${
            styles.component_view
          } flex-95 layout-row layout-wrap layout-align-start-start`}
        >
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title} buffer_10`}
          >
            <div className={`flex layout-row layout-align-start-center ${hubStyles.header_bar_grey}`}>
              <p className={`flex-none ${hubStyles.header_bar_grey_text}`}>
                Hub
              </p>
            </div>
            {hub.hub_status === 'active' ? deactivate : activate}

            <div className={`flex-none layout-row layout-align-center-center ${hubStyles.header_bar_action_buttons}`}>
              <div className="flex-none layout-row pointy layout-align-center-center" onClick={() => this.toggleEdit()} >
                <i className={`flex-none fa fa-pencil ${hubStyles.edit_icon}`} />
              </div>
              <div className="flex-none layout-row pointy layout-align-center-center" onClick={() => this.confirmDelete()}>
                <i className={`flex-none fa fa-times ${hubStyles.delete_icon}`} />
              </div>
            </div>

          </div>
          <div className="flex-100 layout-row layout-align-space-between-center buffer_10">
            <div className={`flex flex-xs-100 flex-sm-100 layout-row layout-align-center-center ${hubStyles.hub_title}`} style={gradientBackground} >
              <div className={`flex-none layout-row layout-align-space-between-center ${hubStyles.hub_title_content}`}>
                <div className="flex-70 layout-row layout-align-start-center">
                  <h3 className="flex-none"> {hub.nexus.name}</h3>
                </div>
                <div className="flex-30 layout-row layout-align-end-center">
                  <div className="flex-none layout-row layout-align-center-center">
                    <h4 className="flex-none" > {renderHubType(hub.hub_type)}</h4>
                  </div>
                  <div className="flex-none layout-row layout-align-center-center" style={{ color: primary }} >
                    {switchIcon(hub.hub_type)}
                  </div>
                </div>
              </div>
            </div>
            <div className={`flex layout-row flex-xs-100 flex-sm-100 ${hubStyles.location_data_box}`}>
              <div className={`flex-55 layout-row ${hubStyles.address_box}`}>
                <div className={`flex-none layout-column layout-align-center-center ${hubStyles.location_icon}`}>
                  <i className="flex-none fa fa-map-marker clip" style={gradientIcon} />
                </div>
                <div className="flex layout-column layout-align-space-around-start">
                  <div className="flex-none layout-row layout-wrap ">
                    <p className={`flex-100  ${hubStyles.address_part_1}`}>{addressString1}</p>
                    <p className={`flex-100  ${hubStyles.address_part_2}`}>{addressString2}</p>
                  </div>
                </div>
              </div>
              <div className={`flex-45 layout-row ${hubStyles.lat_lng_box}`}>
                <div className="flex-50 layout-column layout-align-center-center">
                  <p className={`flex-90 ${hubStyles.lat_lng}`}>{location.latitude}</p>
                  <p className={`flex-90 ${hubStyles.lat_lng}`}>Latitude</p>
                </div>
                <div className={`flex-none ${hubStyles.lat_lng_divider}`} />
                <div className="flex-50 layout-column layout-align-center-center">
                  <p className={`flex-90 ${hubStyles.lat_lng}`}>{location.longitude}</p>
                  <p className={`flex-90 ${hubStyles.lat_lng}`}>Longitude</p>
                </div>
              </div>
            </div>
          </div>

          <div className="flex-100 layout-row layout-align-space-between-center buffer_10">
            <div className={`flex-25 layout-row layout-align-center-center ${hubStyles.hub_photo}`} style={gradientBackground} >
              <div className={`flex-none layout-row layout-align-space-between-center ${hubStyles.hub_photo_content}`} >
                <img src={hub.photo} alt="" />
              </div>
            </div>
            <div className={`flex layout-row ${hubStyles.map_box}`} ref={(mapElement) => { this.mapElement = mapElement }} >
              <GmapsWrapper
                theme={theme}
                component={Map}
                location={hub.location}
                height="170px"
                zoom={12}
              />
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-start-start layout-wrap section_padding">
            <AdminHubFees
              theme={theme}
              charges={charges}
              customs={customs}
              adminDispatch={adminActions}
              loadType={currentFeeLoadType.value}
            />
          </div>
          <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
            <div className="flex-100 flex-gt-sm-33 layout-row layout-align-start-center">
              <AlternativeGreyBox
                wrapperClassName="layout-row flex-100 layout-align-center-center"
                contentClassName="layout-row flex-100 layout-wrap"
                title="Mandatory Charges"
                content={mandatoryChargeBox}
              />
            </div>
            <div className="flex-100 flex-gt-sm-60 layout-row layout-align-start-center">
              <AlternativeGreyBox
                wrapperClassName="layout-row flex-100 layout-align-center-center"
                contentClassName="layout-row flex-100 layout-wrap"
                title="Itineraries"
                content={itinerariesBox}
              />
            </div>
          </div>
          {confimPrompt}
        </div>
        {styleTagJSX}
      </div>
    )
  }
}
AdminHubView.propTypes = {
  theme: PropTypes.theme,
  hubHash: PropTypes.objectOf(PropTypes.hub),
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
    location: PropTypes.objectOf(PropTypes.any),
    mandatoryCharges: PropTypes.objectOf(PropTypes.any)
  })
}

AdminHubView.defaultProps = {
  theme: null,
  hubData: {},
  hubHash: {}
}

export default AdminHubView
