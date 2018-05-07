import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../../prop-types'
import styles from './Card.scss'
import adminStyles from '../Admin.scss'
import { CardTitle, CardRoutesPricing, PricingButton } from './SubComponents'
// import { RoundButton } from '../../RoundButton/RoundButton'
import FileUploader from '../../FileUploader/FileUploader'
import DocumentsDownloader from '../../Documents/Downloader'
import { adminPricing as priceTip } from '../../../constants'
import PricingSearchBar from './SubComponents/PricingSearchBar'
import { filters } from '../../../helpers'

export default class CardPricingIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      itineraries: props.itineraries,
      expander: {},
      searchTexts: {}
    }
    this.handleClick = this.handleClick.bind(this)
    this.iconClasses = {
      ocean: 'anchor',
      air: 'paper-plane',
      rail: 'subway'
    }
  }

  handleClick (id) {
    const { adminDispatch } = this.props
    adminDispatch.getItineraryPricings(id, true)
  }
  generateViewType (mot, limit) {
    return (
      <div className="layout-row flex-100 layout-align-start-center ">
        <div className="layout-row flex-none layout-align-start-center layout-wrap">
          {this.generateCardPricings(mot, limit)}
        </div>
      </div>
    )
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  generateCardPricings (mot, limit) {
    const { itineraries } = this.state
    const { hubs, theme } = this.props
    console.log(mot, limit)
    let itinerariesArr = []
    const viewLimit = limit || 3
    if (itineraries && itineraries.length > 0) {
      itinerariesArr = this.updateSearch(itineraries, mot)
        .filter(itinerary => itinerary.mode_of_transport === mot)
        .map((rt, i) => {
          if (i <= viewLimit) {
            return (
              <CardRoutesPricing
                key={v4()}
                hubs={hubs}
                itinerary={rt}
                theme={theme}
                handleClick={this.handleClick}
              />
            )
          }
          return ''
        })
    } else if (this.props.itineraries && this.props.itineraries.length > 0) {
      itinerariesArr = this.updateSearch(itineraries, mot)
        .filter(itinerary => itinerary.mode_of_transport === mot)
        .map((rt, i) => {
          if (i <= viewLimit) {
            return (
              <CardRoutesPricing
                key={v4()}
                hubs={hubs}
                itinerary={rt}
                theme={theme}
                handleClick={this.handleClick}
              />
            )
          }
          return ''
        })
    }
    return itinerariesArr
  }
  lclUpload (file) {
    const { documentDispatch } = this.props
    documentDispatch.uploadPricings(file, 'lcl', false)
  }
  updateSearch (array, mot) {
    const { searchTexts } = this.state
    return filters.handleSearchChange(searchTexts[mot], ['name'], array)
  }
  handlePricingSearch (event, target) {
    this.setState(
      {
        searchTexts: {
          ...this.state.searchTexts,
          [target]: event.target.value
        }
      },
      this.updateSearch()
    )
  }

  render () {
    const { expander, searchTexts } = this.state
    const {
      theme, limit, scope, toggleCreator
    } = this.props
    if (!scope) return ''
    const sectionStyle =
      theme && theme.colors
        ? { background: theme.colors.secondary, color: 'white' }
        : { background: 'darkslategrey', color: 'white' }
    const modesOfTransport = scope.modes_of_transport
    const modeOfTransportNames = Object.keys(modesOfTransport).filter(modeOfTransportName =>
      Object.values(modesOfTransport[modeOfTransportName]).some(bool => bool))
    const columnFlex = modeOfTransportNames.length === 3 ? 'flex-33' : 'flex-45'
    return (
      <div className="flex-100 layout-row layout-align-space-around-start">
        <div
          className={`${
            styles.flex_titles
          } flex-80 layout-row layout-wrap layout-align-center-start`}
        >
          {modeOfTransportNames.map(modeOfTransportName => (
            <div
              className={`${columnFlex} flex-sm-45 flex-md-45 layout-row layout-wrap layout-align-center-start ${
                styles.titles_btn
              }`}
            >
              <CardTitle
                titles={`${modeOfTransportName} freight`}
                faIcon={this.iconClasses[modeOfTransportName]}
                theme={theme}
              />
              <PricingSearchBar
                onChange={(e, t) => this.handlePricingSearch(e, t)}
                value={searchTexts[modeOfTransportName]}
                target={modeOfTransportName}
              />
              <div className="flex-90 layout-row layout-align-center-start">
                {this.generateViewType(modeOfTransportName, limit)}
              </div>
              <PricingButton
                onClick={toggleCreator}
                onDisabledClick={() => console.log('this button is disabled')}
              />
            </div>
          ))}
        </div>
        <div className="flex-20 layout-row layout-wrap layout-align-center-start">
          <div
            className={`${
              adminStyles.action_box
            } flex-95 layout-row layout-wrap layout-align-center-start`}
          >
            <div
              className={`${adminStyles.side_title} flex-100 layout-row layout-align-start-center`}
              style={sectionStyle}
            >
              <i className="flex-none fa fa-bolt" />
              <h2 className="flex-none letter_3 no_m"> Actions </h2>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${
                  adminStyles.action_header
                } flex-100 layout-row layout-align-start-center`}
                onClick={() => this.toggleExpander('upload')}
              >
                <div className="flex-90 layout-align-start-center layout-row">
                  <i className="flex-none fa fa-cloud-upload" />
                  <p className="flex-none">Upload Data</p>
                </div>
                <div className={`${adminStyles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.upload ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.upload ? adminStyles.open_filter : adminStyles.closed_filter
                } flex-100 layout-row layout-wrap layout-align-center-start`}
              >
                <div
                  className={`${
                    adminStyles.action_section
                  } flex-100 layout-row layout-align-center-center layout-wrap`}
                >
                  <p className="flex-100">Upload FCL/LCL Pricings Sheet</p>
                  <FileUploader
                    theme={theme}
                    dispatchFn={e => this.lclUpload(e)}
                    tooltip={priceTip.upload_lcl}
                    type="xlsx"
                    text="Dedicated Pricings .xlsx"
                  />
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${
                  adminStyles.action_header
                } flex-100 layout-row layout-align-start-center`}
                onClick={() => this.toggleExpander('download')}
              >
                <div className="flex-90 layout-align-start-center layout-row">
                  <i className="flex-none fa fa-cloud-download" />
                  <p className="flex-none">Download Data</p>
                </div>
                <div className={`${adminStyles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.download ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.download ? adminStyles.open_filter : adminStyles.closed_filter
                } flex-100 layout-row layout-wrap layout-align-center-start`}
              >
                <div
                  className={`${
                    adminStyles.action_section
                  } flex-100 layout-row layout-wrap layout-align-center-center`}
                >
                  <p className="flex-100">Download Pricings Sheet</p>
                  <DocumentsDownloader theme={theme} target="pricing" />
                </div>
              </div>
            </div>
            {/* <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${
                  adminStyles.action_header
                } flex-100 layout-row layout-align-start-center`}
                onClick={() => this.toggleExpander('new')}
              >
                <div className="flex-90 layout-align-start-center layout-row">
                  <i className="flex-none fa fa-plus-circle" />
                  <p className="flex-none">Create New Hub</p>
                </div>
                <div className={`${adminStyles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.new ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.new ? adminStyles.open_filter : adminStyles.closed_filter
                } flex-100 layout-row layout-wrap layout-align-center-start`}
              >
                <div
                  className={`${
                    adminStyles.action_section
                  } flex-100 layout-row layout-wrap layout-align-center-center`}
                >
                  {newButton}
                </div>
              </div>
            </div> */}
          </div>
        </div>
      </div>
    )
  }
}
CardPricingIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  itineraries: PropTypes.arrayOf(PropTypes.itinerary),
  limit: PropTypes.number,
  toggleCreator: PropTypes.func,
  adminDispatch: PropTypes.shape({
    getClientPricings: PropTypes.func,
    getRoutePricings: PropTypes.func
  }).isRequired,
  documentDispatch: PropTypes.shape({
    closeViewer: PropTypes.func,
    uploadPricings: PropTypes.func
  }).isRequired,
  scope: PropTypes.scope
}

CardPricingIndex.defaultProps = {
  theme: null,
  hubs: [],
  itineraries: [],
  scope: null,
  limit: 4,
  toggleCreator: null
}
