import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import Fuse from 'fuse.js'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import Toggle from 'react-toggle'
import GmapsWrapper from '../../hocs/GmapsWrapper'
import '../../styles/react-toggle.scss'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import {
  history,
  capitalize,
  nameToDisplay,
  gradientGenerator
} from '../../helpers'
import { TruckingDisplayPanel } from './AdminAuxilliaries'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import DocumentsSelector from '../Documents/Selector'
import TruckingCoverage from './Trucking/Coverage'
import TruckingRateTable from './Trucking/RateTable'
import { documentActions } from '../../actions'
import AdminUploadsSuccess from './Uploads/Success'
import DocumentsDownloader from '../Documents/Downloader'
import { cargoClassOptions } from '../../constants'
import GreyBox from '../GreyBox/GreyBox'
import SideOptionsBox from './SideOptions/SideOptionsBox'
import CollapsingBar from '../CollapsingBar/CollapsingBar'


function getTruckingPricingKey (truckingPricing) {
  if (truckingPricing.zipcode) {
    const joinedArrays = truckingPricing.zipcode.map(zArray => zArray.join(' - '))
    const endResult = joinedArrays.join(', ')

    return endResult
  }
  if (truckingPricing.city) {
    const joinedArrays = truckingPricing.city.map(zArray => zArray.join(' - '))
    const endResult = joinedArrays.join(', ')

    return endResult
  }
  if (truckingPricing.distance) {
    const joinedArrays = truckingPricing.distance.map(zArray => zArray.join(' - '))
    const endResult = joinedArrays.join(', ')

    return endResult
  }

  return ''
}

export class AdminTruckingView extends Component {
  static backToIndex () {
    history.goBack()
  }

  constructor (props) {
    super(props)
    this.state = {
      loadTypeBool: true,
      directionBool: true,
      truckBool: true,
      filteredTruckingPricings: [],
      searchFilter: '',
      cargoClass: { value: 'fcl_20', label: 'FCL 20ft' },
      expander: {}
    }
    this.setCurrentTruckingPricing = this.setCurrentTruckingPricing.bind(this)
  }

  componentWillMount () {
    if (this.props.truckingDetail && this.props.truckingDetail.truckingPricings) {
      this.handleSearchChange({ target: { value: '' } })
    }
  }

  componentDidMount () {
    window.scrollTo(0, 0)
    if (this.state.filteredTruckingPricings.length === 0 &&
      this.props.truckingDetail &&
      this.props.truckingDetail.truckingPricings.length > 0) {
      this.handleLoadTypeToggle()
    }
  }

  filterTruckingPricingsByType (pricings) {
    const {
      loadTypeBool, directionBool, truckBool, cargoClass
    } = this.state
    const loadTypeKey = loadTypeBool ? 'container' : 'cargo_item'
    const directionKey = directionBool ? 'pre' : 'on'
    const truckKey = truckBool ? 'chassis' : 'side_lifter'
    if (loadTypeBool) {
      return pricings
        .filter(pr => pr.truckingPricing.load_type === loadTypeKey)
        .filter(pr => pr.truckingPricing.carriage === directionKey)
        .filter(pr => pr.truckingPricing.truck_type === truckKey)
        .filter(pr => pr.truckingPricing.cargo_class === cargoClass.value)
    }

    return pricings
      .filter(pr => pr.truckingPricing.load_type === loadTypeKey)
      .filter(pr => pr.truckingPricing.carriage === directionKey)
  }

  toggleNew () {
    this.setState({ newRow: !this.state.newRow })
  }

  selectTruckingPricing (truckingPricing) {
    this.setCurrentTruckingPricing(truckingPricing.truckingPricing.id)
  }

  setCurrentTruckingPricing (id) {
    this.setState({ currentTruckingPricing: id })
  }

  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }

  handleUpload (file, dir, type) {
    const { adminDispatch, truckingDetail } = this.props
    const { hub } = truckingDetail
    const url = `/admin/trucking/trucking_pricings/${hub.id}`
    adminDispatch.uploadTrucking(url, file, dir)
  }

  handleLoadTypeToggle (value) {
    this.setState({ loadTypeBool: !this.state.loadTypeBool }, () => {
      if (this.state.loadTypeBool) {
        this.setState({ truckBool: false })
      }
      this.handleSearchChange({ target: { value: '' } })
    })
  }

  handleTruckToggle (value) {
    this.setState({ truckBool: !this.state.truckBool }, () => {
      this.handleSearchChange({ target: { value: '' } })
    })
  }

  handleDirectionToggle (value) {
    this.setState({ directionBool: !this.state.directionBool }, () => {
      this.handleSearchChange({ target: { value: '' } })
    })
  }

  handleCargoClass (selection) {
    this.setState({ cargoClass: selection }, () => {
      this.handleSearchChange({ target: { value: '' } })
    })
  }

  backToList () {
    this.setState({ currentTruckingPricing: false })
  }

  closeSuccessDialog () {
    const { documentDispatch } = this.props
    documentDispatch.closeViewer()
  }

  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        filteredTruckingPricings:
        this.filterTruckingPricingsByType(this.props.truckingDetail.truckingPricings)
      })

      return
    }
    const search = (key) => {
      const options = {
        shouldSort: true,
        tokenize: true,
        threshold: 0.2,
        location: 0,
        distance: 50,
        maxPatternLength: 32,
        minMatchCharLength: 5,
        keys: key
      }
      const fuse = new Fuse(this.props.truckingDetail.truckingPricings, options)

      return fuse.search(event.target.value)
    }

    const filteredTruckingPricings = search(['zipcode', 'city', 'distance'])
    // ;
    this.setState({
      filteredTruckingPricings: this.filterTruckingPricingsByType(filteredTruckingPricings),
      searchFilter: event.target.value
    })
  }

  render () {
    const {
      t, theme, truckingDetail, adminDispatch, document
    } = this.props
    if (!truckingDetail) {
      return ''
    }

    const {
      filteredTruckingPricings,
      searchFilter,
      currentTruckingPricing,
      loadTypeBool,
      directionBool,
      truckBool,
      cargoClass
    } = this.state
    // const truckType = truckBool ? 'chassis' : 'side_lifter'
    const uploadStatus = document.viewer ? (
      <AdminUploadsSuccess
        theme={theme}
        data={document.results}
        closeDialog={() => this.closeSuccessDialog()}
      />
    ) : (
      ''
    )
    const { hub, coverage } = truckingDetail
    const { primary, secondary } = theme.colors
    const gradientBackground = gradientGenerator(primary, secondary)
    const truckingPricingToDisplay =
      truckingDetail.truckingPricings
        .filter(tp => tp.truckingPricing.id === currentTruckingPricing)[0]
    const displayPanel = (
      <TruckingDisplayPanel
        theme={theme}
        truckingInstance={truckingPricingToDisplay}
        closeView={this.closeQueryView}
        adminDispatch={adminDispatch}
      />
    )
    const toggleCSS = `
      .react-toggle--checked .react-toggle-track {
        background:
          ${theme.colors.brightPrimary} !important;
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
      .react-toggle-track {
        background: ${theme.colors.brightSecondary} !important;
      }
      .react-toggle:hover .react-toggle-track{
        background: rgba(0, 0, 0, 0.5) !important;
      }
    `
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''

    const { expander } = this.state
    const searchResults =
      filteredTruckingPricings.length > 0 ? (
        filteredTruckingPricings.map((tp) => {
          const idenitfierKey = Object.keys(tp).filter(key => key !== 'truckingPricing' && key !== 'countryCode')[0]

          return (
            <div className="flex-100 layout-row layout-align-center-stretch five_p">
              <GreyBox
                isBox
                padding
                content={(
                  <div
                    className={`flex-100 layout-row layout-align-center-center pointy layout-wrap ${
                      styles.trucking_display_cell
                    }`}
                    key={v4()}
                    onClick={() => this.selectTruckingPricing(tp)}
                  >
                    {loadTypeBool
                      ? (
                        <div className="flex-66 layout-row layout-align-center-center">
                          <p className="flex-50">{nameToDisplay(tp.truckingPricing.cargo_class)}</p>
                          <p className={`flex-50 ${styles.truck_type_border}`}>{nameToDisplay(tp.truckingPricing.truck_type)}</p>
                        </div>
                      )
                      : ''
                    }
                    {idenitfierKey === 'distance' ? (
                      <div className="flex-33 layout-column layout-wrap layout-align-center-center">
                        <p className="flex-90">{capitalize(idenitfierKey)}</p>
                        <p className="flex-90">
                          {' '}
                          {getTruckingPricingKey(tp)}
                        </p>
                      </div>
                    ) : (
                      <div className="flex-100 layout-row layout-wrap layout-align-center-center">
                        <p className="flex-90">
                          {capitalize(idenitfierKey)}
                          {' '}
                          {getTruckingPricingKey(tp)}
                        </p>
                      </div>
                    )}

                  </div>
                )}
              />
            </div>

          )
        })
      ) : (
        <div className="flex-100 layout-row layout-align-center-center">
          <p className="flex-none">{t('admin:noTruckingsAvailable')}</p>
        </div>
      )
    const backBtn = (
      <div
        className={`flex-20 layout-row pointy layout-align-end-center ${styles.back_button}`}
        onClick={() => this.backToList()}
      >
        <div className="flex-none layout-row layout-align-center-center">
          <i className="flex-none fa fa-angle-left" />
          <p className="flex-none">
&nbsp;&nbsp;
            {t('admin:backToList')}
          </p>
        </div>
      </div>)
    const truckView = currentTruckingPricing ? displayPanel : searchResults
    const truckFilter = loadTypeBool
      ? (
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-90 layout-row layout-align-space-between-center">
            <p className="flex-none">{t('admin:sideLifter')}</p>
            <div className="flex-5" />
            <Toggle
              className="flex-none"
              id="unitView"
              name="unitView"
              checked={truckBool}
              onChange={e => this.handleTruckToggle(e)}
            />
            <div className="flex-5" />
            <p className="flex-none">{t('admin:chassis')}</p>
          </div>
        </div>
      ) : ''

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start padd_20">
        {uploadStatus}
        <div className={`${styles.component_view} flex-100 layout-row layout-align-start-start`}>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div className="flex-60 layout-row layout-align-space-around-start layout-wrap">
              <div className="flex-100 layout-row layout-align-start-stretch layout-wrap">
                <GmapsWrapper
                  onMapClick={this.setCurrentTruckingPricing}
                  location={hub}
                  component={TruckingCoverage}
                  coverage={coverage}
                />
              </div>
            </div>

            <div className="flex-40 layout-row layout-align-space-around-start layout-wrap">
              <div className="flex-100 layout-row layout-align-start-stretch layout-wrap">
                {/* {truckView} */}
                <TruckingRateTable />
              </div>
            </div>

          </div>
          {styleTagJSX}
        </div>
        {/* <div className="flex-20 layout-row layout-wrap layout-align-center-start"> 

          <SideOptionsBox
            header={t('admin:filters')}
            flexOptions="layout-column flex-100 flex-md-30"
            content={(
              <div>
                <div
                  className="flex-100 layout-row layout-wrap layout-align-center-start input_box_full"
                >
                  <input
                    type="text"
                    value={searchFilter}
                    placeholder={t('admin:searchTruckingZones')}
                    onChange={e => this.handleSearchChange(e)}
                  />
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    showArrow
                    collapsed={!expander.load_type}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('load_type')}
                    styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                    text={t('admin:loadType')}
                    faClass="fa fa-ship"
                    content={(
                      <div className="flex-90 layout-row layout-align-space-between-center">
                        <p className="flex-none">LTL</p>
                        <div className="flex-5" />
                        <Toggle
                          className="flex-none"
                          id="unitView"
                          name="unitView"
                          checked={loadTypeBool}
                          onChange={e => this.handleLoadTypeToggle(e)}
                        />
                        <div className="flex-5" />
                        <p className="flex-none">FTL</p>
                      </div>
                    )}
                  />
                </div>

                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    showArrow
                    collapsed={!expander.direction}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('direction')}
                    styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                    text={`${t('admin:import')} / ${t('admin:export')}`}
                    faClass="fa fa-star-half-o"
                    content={(
                      <div className="flex-90 layout-row layout-align-space-between-center">
                        <p className="flex-none">{t('admin:export')}</p>
                        <div className="flex-5" />
                        <Toggle
                          className="flex-none"
                          id="unitView"
                          name="unitView"
                          checked={directionBool}
                          onChange={e => this.handleDirectionToggle(e)}
                        />
                        <div className="flex-5" />
                        <p className="flex-none">{t('admin:import')}</p>
                      </div>
                    )}
                  />
                </div>
                {loadTypeBool
                  ? (
                    <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                      <CollapsingBar
                        showArrow
                        collapsed={!expander.truck_type}
                        theme={theme}
                        handleCollapser={() => this.toggleExpander('truck_type')}
                        styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                        text={`${t('admin:import')} / ${t('admin:export')}`}
                        faClass="fa fa-flag"
                        content={truckFilter}
                      />
                    </div>
                  ) : ''}
                {loadTypeBool
                  ? (
                    <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                      <CollapsingBar
                        showArrow
                        collapsed={!expander.cargo_class}
                        theme={theme}
                        handleCollapser={() => this.toggleExpander('cargo_class')}
                        styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                        text={t('admin:cargoClassPlain')}
                        faClass="fa fa-flag"
                        content={(
                          <NamedSelect
                            placeholder={t('admin:cargoClassPlain')}
                            className={styles.select}
                            name="cargo_class"
                            value={cargoClass}
                            options={cargoClassOptions}
                            onChange={e => this.handleCargoClass(e)}
                          />
                        )}
                      />
                    </div>
                  ) : ''}
              </div>
            )}
          />

          <SideOptionsBox
            header={t('admin:dataManager')}
            flexOptions="layout-column flex-100 flex-md-30 margin_bottom"
            content={(
              <div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    showArrow
                    collapsed={!expander.upload}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('upload')}
                    styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                    text={t('admin:uploadData')}
                    faClass="fa fa-cloud-upload"
                    content={(
                      <div
                        className={`${
                          styles.action_section
                        } flex-100 layout-row layout-align-center-center layout-wrap`}
                      >
                        <p className="flex-90 center">{t('admin:uploadTruckingZonesSheet')}</p>
                        <DocumentsSelector
                          theme={theme}
                          dispatchFn={(file, dir) => this.handleUpload(file, dir)}
                          type="xlsx"
                          text={t('admin:routesExcel')}
                        />
                      </div>
                    )}
                  />
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    showArrow
                    collapsed={!expander.download}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('download')}
                    styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                    text={t('admin:downloadData')}
                    faClass="fa fa-cloud-download"
                    content={(
                      <div>
                        <div
                          className={`${
                            styles.action_section
                          } flex-100 layout-row layout-wrap layout-align-center-center`}
                        >
                          <p className="flex-100 center">{t('admin:downloadCargoItemSheet')}</p>
                          <DocumentsDownloader
                            theme={theme}
                            target="trucking"
                            options={{ hub_id: hub.id, load_type: 'cargo_item' }}
                          />
                        </div>
                        <div
                          className={`${
                            styles.action_section
                          } flex-100 layout-row layout-wrap layout-align-center-center`}
                        >
                          <p className="flex-100 center">{t('admin:downloadContainerSheet')}</p>
                          <DocumentsDownloader
                            theme={theme}
                            target="trucking"
                            options={{ hub_id: hub.id, load_type: 'container' }}
                          />
                        </div>
                      </div>
                    )}
                  />
                </div>
              </div>
            )}
          />
        </div>*/}
      </div>
    )
  }
}
AdminTruckingView.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  adminDispatch: PropTypes.shape({
    uploadTrucking: PropTypes.func
  }).isRequired,
  truckingDetail: PropTypes.shape({
    truckingHub: PropTypes.object,
    truckingPricings: PropTypes.array,
    pricing: PropTypes.object
  }),
  document: PropTypes.objectOf(PropTypes.any),
  documentDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminTruckingView.defaultProps = {
  theme: null,
  truckingDetail: null,
  document: {},
  documentDispatch: {}
}
function mapStateToProps (state) {
  const { document } = state

  return {
    document
  }
}
function mapDispatchToProps (dispatch) {
  return {
    documentDispatch: bindActionCreators(documentActions, dispatch)
  }
}

export default withNamespaces('admin')(connect(mapStateToProps, mapDispatchToProps)(AdminTruckingView))
