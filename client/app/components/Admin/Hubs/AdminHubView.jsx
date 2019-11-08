import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import { AdminHubTile } from '..'
import styles from '../Admin.scss'
import { adminClicked as clickTool } from '../../../constants'
import AdminHubFees from './Fees'
import AdminPromptConfirm from '../Prompt/Confirm'
import hubStyles from './index.scss'
import '../../../styles/react-toggle.scss'
import {
  gradientGenerator,
  gradientTextGenerator,
  switchIcon,
  renderHubType,
  capitalize,
  gradientBorderGenerator
} from '../../../helpers'
import MandatoryChargeBox from './MandatoryChargeBox'
import GreyBox from '../../GreyBox/GreyBox'
import ItineraryRow from '../Itineraries/ItineraryRow'
import AdminHubEdit from './AdminHubEdit'
import { SimpleMap as Map } from '../../Maps/SimpleMap'
import GmapsWrapper from '../../../hocs/GmapsWrapper'
import GradientBorder from '../../GradientBorder'

export class AdminHubView extends Component {
  constructor (props) {
    super(props)
    this.state = {
      currentFeeLoadType: { value: 'lcl', label: 'Lcl' },
      editedHub: { data: {}, address: {} },
      mandatoryCharge: {},
      editView: false,
      page: 1,
      numPerPage: 10
    }
    this.toggleHubActive = this.toggleHubActive.bind(this)
    this.getItineraryFromLayover = this.getItineraryFromLayover.bind(this)
  }

  componentDidMount () {
    this.checkAndSetCharges(this.props)
    this.prepPages()
  }

  componentWillReceiveProps (nextProps) {
    if (!this.state.mapWidth) {
      const mapWidth = this.mapElement ? this.mapElement.clientWidth : '1000'
      this.setState({ mapWidth })
    }
    if (!this.state.editedHub.data.name) {
      this.setState({
        editedHub: { data: nextProps.hubData.hub, address: nextProps.hubData.address }
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
        !this.state.mandatoryCharge || (nextProps.hubData.mandatoryCharge !== this.state.mandatoryCharge)
      ) {
        const { mandatoryCharge } = nextProps.hubData
        this.setState({ mandatoryCharge })
      }
    }
  }

  getItineraryFromLayover (id) {
    const { routes } = this.props.hubData

    return routes.filter(x => x.id === id)[0]
  }

  deltaPage (val) {
    this.setState((prevState) => {
      const newPageVal = prevState.page + val
      const page = (newPageVal < 1 && newPageVal > prevState.numPages) ? 1 : newPageVal

      return { page }
    })
  }

  prepPages () {
    const { hubData } = this.props
    const { routes } = hubData
    const numPages = Math.ceil(routes.length / 12)
    this.setState({ numPages })
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
      theme, hubData, hubHash, adminActions, t
    } = this.props
    const {
      currentFeeLoadType,
      editView,
      confirm,
      mandatoryCharge,
      page,
      numPages,
      numPerPage
    } = this.state
    if (!hubData || !theme) {
      return ''
    }

    const {
      hub, relatedHubs, routes, address
    } = hubData
    if (!hub) {
      return ''
    }
    const { primary, secondary } = theme.colors
    const textStyle = gradientTextGenerator(primary, secondary)
    const borderStyle = gradientBorderGenerator(primary, secondary)
    const gradientBackground = gradientGenerator(primary, secondary)
    const gradientIcon = gradientTextGenerator(primary, secondary)

    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={t('admin:deleteHub', { name: hub.name })}
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
        style={gradientBackground}
        onClick={this.toggleHubActive}
      >
        <p className="flex-none">
          {capitalize(hub.hub_status)}
        </p>
      </div>
    )

    const editorModal = (
      <AdminHubEdit
        hub={hub}
        theme={theme}
        saveHub={this.saveHub}
        adminDispatch={adminActions}
        close={() => this.toggleEdit()}
      />
    )
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
    const addressString1 = `${hub.address.street_number || ''} ${hub.address.street || ''}, ${hub.address.zip_code || ''}`
    const addressString2 = `${hub.address.city || ''} ${hub.address.country.name || ''}`
    const mandatoryChargeBox = (
      <MandatoryChargeBox
        mandatoryCharge={mandatoryCharge}
        theme={theme}
        saveChanges={e => this.saveMandatoryChargeEdit(e)}
      />
    )
    const gradientBorderStyle =
    theme && theme.colors
      ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: 'black' }
    const sliceStartIndex = (page - 1) * numPerPage
    const sliceEndIndex = (page * numPerPage)
    const itinerariesBox =
    (
      <div className="flex-100 layout-row layout-wrap">
        {routes
          .slice(sliceStartIndex, sliceEndIndex)
          .map(r => (
            <ItineraryRow
              itinerary={r}
              theme={theme}
              adminDispatch={adminActions}
            />
          ))}
        <div className="flex-100 layout-row layout-align-center-center margin_bottom">
          <div
            className={`
                flex-15 layout-row layout-align-center-center pointy
                ${styles.navigation_button} ${page === 1 ? styles.disabled : ''}
              `}
            onClick={page > 1 ? () => this.deltaPage(-1) : null}
          >
            <i className="fa fa-chevron-left" />
            <p className={styles.pager_button} >
              {t('common:basicBack')}
            </p>
          </div>
          {}
          <p>{page}</p>
          <div
            className={`
                flex-15 layout-row layout-align-center-center pointy
                ${styles.navigation_button} ${page < numPages ? '' : styles.disabled}
              `}
            onClick={page < numPages ? () => this.deltaPage(1) : null}
          >
            <p className={styles.pager_button} >
              {t('common:next')}
            </p>
            <i className="fa fa-chevron-right" />
          </div>
        </div>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start extra_padding">
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
                {t('admin:hub')}
              </p>
            </div>
            {hub.hub_status === 'active' ? deactivate : activate}

            <div className={`flex-none layout-row layout-align-center-center ${hubStyles.header_bar_action_buttons}`}>
              <div className="flex-none layout-row pointy layout-align-center-center" onClick={() => this.toggleEdit()}>
                <i className={`flex-none fa fa-pencil ${hubStyles.edit_icon}`} />
              </div>
              <div className="flex-none layout-row pointy layout-align-center-center" onClick={() => this.confirmDelete()}>
                <i className={`flex-none fa fa-times ${hubStyles.delete_icon}`} />
              </div>
            </div>

          </div>

          <div className="flex-100 layout-row layout-wrap layout-align-space-between-stretch">
            <div className="flex-50 layout-row layout-wrap layout-align-space-between-stretch">
              <GradientBorder
                wrapperClassName="flex-100 layout-row layout-align-space-between-stretch"
                className="flex-100 layout-row"
                gradient={gradientBorderStyle}
                content={(
                  <div className={`flex-none layout-row layout-align-space-between-center ${hubStyles.hub_title_content}`}>
                    <div className="flex-70 layout-row layout-align-start-center">
                      <h3 className="flex-none">
                        {' '}
                        {hub.nexus.name}
                      </h3>
                    </div>
                    <div className="flex-30 layout-row layout-align-end-center">
                      <div className="flex-none layout-row layout-align-center-center">
                        <h4 className="flex-none">
                          {' '}
                          {renderHubType(hub.hub_type)}
                        </h4>
                      </div>
                      <div className="flex-none layout-row layout-align-center-center" style={{ color: primary }}>
                        {switchIcon(hub.hub_type)}
                      </div>
                    </div>
                  </div>
                )}
              />
              <div className={`flex-100 layout-row ${hubStyles.address_data_box}`}>
                <div className={`flex-55 layout-row ${hubStyles.address_box}`}>
                  <div className={`flex-none layout-column layout-align-start-center ${hubStyles.address_icon}`}>
                    <i className="flex-none fa fa-map-marker clip" style={gradientIcon} />
                  </div>
                  <div className="flex layout-align-space-around-start">
                    <div className="flex-none layout-row layout-wrap ">
                      <p className={`flex-100  ${hubStyles.address_part_1}`}>
                        {addressString1}
                        <br />
                        <strong>{addressString2}</strong>
                      </p>
                    </div>
                  </div>
                  <div className={`flex-none ${hubStyles.address_divider}`} />
                </div>

                <div className={`flex-45 layout-row ${hubStyles.lat_lng_box}`}>
                  <div className="flex-50 layout-column layout-align-center-center">
                    <p className={` ${hubStyles.lat_lng}`}>{address.latitude}</p>
                    <p className={` ${hubStyles.lat_lng}`}>{t('admin:latitude')}</p>
                  </div>
                  <div className={`flex-none ${hubStyles.lat_lng_divider}`} />
                  <div className="flex-50 layout-column layout-align-center-center">
                    <p className={` ${hubStyles.lat_lng}`}>{address.longitude}</p>
                    <p className={` ${hubStyles.lat_lng}`}>{t('admin:longitude')}</p>
                  </div>
                </div>
              </div>
            </div>
            <div className="flex-45 layout-row layout-align-center-center buffer_10">
              <div className={`flex layout-row ${hubStyles.map_box}`} ref={(mapElement) => { this.mapElement = mapElement }}>
                <GmapsWrapper
                  theme={theme}
                  component={Map}
                  address={hub.address}
                  height="170px"
                  zoom={12}
                />
              </div>
            </div>
          </div>

          <div className="flex-100 layout-row layout-align-start-start layout-wrap section_padding">
            <AdminHubFees
              theme={theme}
              hubId={hub.id}
              loadType={currentFeeLoadType.value}
            />
          </div>
          <div className="flex-100 layout-row layout-align-space-between-stretch layout-wrap">
            <div className="flex-100 flex-gt-sm-33 layout-row layout-align-start-stretch">
              <GreyBox
                wrapperClassName="layout-row flex-100 layout-align-start-start"
                contentClassName="layout-row flex-100 layout-wrap"
                title={t('admin:mandatoryCharges')}
                content={mandatoryChargeBox}
              />
            </div>
            {console.log(routes)}
            <div className="flex-100 flex-gt-sm-60 layout-row layout-align-start-stretch">
              <GreyBox
                wrapperClassName="layout-row flex-100 layout-align-center-stretch"
                contentClassName="layout-row flex-100 layout-wrap"
                title={t('admin:itineraries')}
                content={routes.length === 0
                  ? (
                    <div className="flex-100 layout-row layout-align-center-center layout-wrap">
                      {t('admin:noItineraries')}
                    </div>
                  )
                  : itinerariesBox}
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
  t: PropTypes.func.isRequired,
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
    serviceLevels: PropTypes.array,
    counterpartHubs: PropTypes.array,
    address: PropTypes.objectOf(PropTypes.any),
    mandatoryCharges: PropTypes.objectOf(PropTypes.any)
  })
}

AdminHubView.defaultProps = {
  theme: null,
  hubData: {},
  hubHash: {}
}

export default withNamespaces(['admin', 'common'])(AdminHubView)
