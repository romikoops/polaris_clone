import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import { snakeCase } from 'lodash'
import PropTypes from '../../../prop-types'
import styles from './Card.scss'
import adminStyles from '../Admin.scss'
import SideOptionsBox from '../SideOptions/SideOptionsBox'
import { CardRoutesPricing } from './SubComponents'
import FileUploader from '../../FileUploader/FileUploader'
import DocumentsDownloader from '../../Documents/Downloader'
import { adminPricing as priceTip } from '../../../constants'
import PricingSearchBar from './SubComponents/PricingSearchBar'
import {
  filters,
  capitalize
} from '../../../helpers'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'
import { RoundButton } from '../../RoundButton/RoundButton'

class CardPricingIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {},
      searchText: '',
      page: 1
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

  generateViewType (mot) {
    return (
      <div className="layout-row flex-100 layout-align-start-center ">
        <div className="layout-row flex-90 layout-align-start-center layout-wrap">
          {this.generateCardPricings(mot)}
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

  generateCardPricings (mot) {
    const { hubs, theme, itineraries } = this.props
    let itinerariesArr = []
    itinerariesArr = itineraries
      .map((rt, i) => (
        <CardRoutesPricing
          key={v4()}
          hubs={hubs}
          itinerary={rt}
          theme={theme}
          handleClick={this.handleClick}
        />
      ))

    return itinerariesArr
  }

  pricingUpload (file, mot, loadType, isOpen) {
    const { documentDispatch } = this.props
    documentDispatch.uploadPricings(file, mot, loadType, isOpen)
  }

  updateSearch (array) {
    const { searchText } = this.state

    return filters.handleSearchChange(searchText, ['name'], array)
  }

  handlePricingSearch (event) {
    const { searchTimeout } = this.state
    if (searchTimeout) {
      window.clearTimeout(searchTimeout)
    }
    const newTimeout = window.setTimeout(this.executeSearch(event.target.value), 750)
    this.setState({
      searchText: event.target.value,
      page: 1,
      searchTimeout: newTimeout
    })
  }

  executeSearch () {
    const { adminDispatch, mot } = this.props
    adminDispatch.searchPricings(this.state.searchText, 1, mot)
  }

  deltaPage (val) {
    const { adminDispatch, mot, allNumPages } = this.props
    const numPages = allNumPages[mot] || 1
    this.setState(
      (prevState) => {
        const newPageVal = prevState.page + val
        const page = (newPageVal < 1 && newPageVal > numPages) ? 1 : newPageVal

        return { page }
      },
      () => {
        const newPagesNumbers = { ...allNumPages, [mot]: this.state.page }
        adminDispatch.getPricings(false, newPagesNumbers)
      }
    )
  }

  render () {
    const { searchText, page, expander } = this.state
    const {
      theme, scope, toggleCreator, mot, allNumPages, t, user
    } = this.props

    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text={t('admin:new')}
          active
          handleNext={toggleCreator}
          iconClass="fa-plus"
        />
      </div>
    )

    if (!scope) return ''
    const numPages = allNumPages[mot] || 1

    const loadTypeOptions = (() => {
      switch (mot) {
        case 'air':
          return { cargoItem: 'LCL' }
        case 'ocean':
          return { cargoItem: 'LCL', container: 'FCL' }
        case 'rail':
          return { cargoItem: 'LCL', container: 'FCL' }
        case 'trucking':
          return { cargoItem: 'LTL', container: 'FTL' }
        default:
          return {}
      }
    })()

    const uploadButtons = (
      <div
        className={`${adminStyles.open_filter} flex-100 layout-row layout-wrap layout-align-center-start`}
      >
        {Object.keys(loadTypeOptions).map((loadType) => {
          const uploadPricingText = (loadType
            ? t('admin:uploadPricingWithLoadType', { mot: capitalize(mot), loadType: loadTypeOptions[loadType].toUpperCase() })
            : t('admin:uploadPricing', { mot: capitalize(mot) })
          )

          const options = { mot }
          if (loadType) options.load_type = snakeCase(loadType)

          return (
            <div
              className={`${
                adminStyles.action_section
              } flex-100 layout-row layout-wrap layout-align-center-center`}
            >
              <p className="flex-100">{uploadPricingText}</p>
              <FileUploader
                theme={theme}
                dispatchFn={file => this.pricingUpload(file, mot, snakeCase(loadType), false)}
                tooltip={priceTip.upload_lcl}
                type="xlsx"
                size="full"
                text={t('admin:dedicatedPricing')}
              />
            </div>
          )
        })}
      </div>
    )

    const downloadButtons = (
      <div
        className={`${adminStyles.open_filter} flex-100 layout-row layout-wrap layout-align-center-start`}
      >
        {Object.keys(loadTypeOptions).map((loadType) => {
          const downloadPricingText = (loadType
            ? t('admin:downloadPricingWithLoadType', { mot: capitalize(mot), loadType: loadTypeOptions[loadType].toUpperCase() })
            : t('admin:downloadPricing', { mot: capitalize(mot) })
          )

          const options = { mot }
          if (loadType) options.load_type = snakeCase(loadType)

          return (
            <div
              className={`${
                adminStyles.action_section
              } flex-100 layout-row layout-wrap layout-align-center-center`}
            >
              <p className="flex-100">{downloadPricingText}</p>
              <DocumentsDownloader
                theme={theme}
                target={`pricing_${snakeCase(loadType)}`}
                options={options}
                size="full"
              />
            </div>
          )
        })}
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-align-md-space-between-start layout-align-space-around-start">

        <div
          className={`${adminStyles.margin_box_right} margin_bottom
          flex-80 flex-sm-100 flex-xs-100 layout-row layout-wrap layout-align-start-start`}
        >

          <div
            className={`flex-100 layout-row layout-wrap layout-align-center-start card_padding_right ${
              styles.titles_btn
            }`}
          >
            <div className="flex-100 layout-row layout-align-center-start" style={{ minHeight: '560px' }}>
              {this.generateViewType(mot)}
            </div>
            <div className="flex-95 layout-row layout-align-center-center margin_bottom">
              <div
                className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${page === 1 ? adminStyles.disabled : ''}
                    `}
                onClick={page > 1 ? () => this.deltaPage(-1) : null}
              >
                <i className="fa fa-chevron-left" />
                <p>
                  {'\u00A0\u00A0\u00A0\u00A0'}
                  {t('common:basicBack')}
                </p>
              </div>
              <p>{page}</p>
              <div
                className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${page < numPages ? '' : adminStyles.disabled}
                    `}
                onClick={page < numPages ? () => this.deltaPage(1) : null}
              >
                <p>
                  {t('common:next')}
                  {'\u00A0\u00A0\u00A0\u00A0'}
                </p>
                <i className="fa fa-chevron-right" />
              </div>
            </div>
          </div>

        </div>
        <div className="flex-20 layout-row layout-align-end-end">

          <div className="hide-sm hide-xs layout-row layout-wrap  flex-100">
            <PricingSearchBar
              onChange={(e, target) => this.handlePricingSearch(e, target)}
              value={searchText}
              target={mot}
            />
            <SideOptionsBox
              header={t('admin:dataManager')}
              flexOptions="flex-100"
              content={(
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  { user.internal ? (
                    <CollapsingBar
                      showArrow
                      collapsed={!expander.upload}
                      theme={theme}
                      styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                      handleCollapser={() => this.toggleExpander('upload')}
                      text={t('admin:uploadData')}
                      faClass="fa fa-cloud-upload"
                      content={uploadButtons}
                    />
                  ) : '' }
                  <CollapsingBar
                    showArrow
                    collapsed={!expander.download}
                    theme={theme}
                    styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                    handleCollapser={() => this.toggleExpander('download')}
                    text={t('admin:downloadData')}
                    faClass="fa fa-cloud-download"
                    content={downloadButtons}
                  />
                  { user.internal ? (
                    <CollapsingBar
                      showArrow
                      collapsed={!expander.new}
                      theme={theme}
                      styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                      handleCollapser={() => this.toggleExpander('new')}
                      text={t('admin:createNewPricing')}
                      faClass="fa fa-plus-circle"
                      content={(
                        <div
                          className={`${
                            styles.action_section
                          } flex-100 layout-row layout-align-center-center layout-wrap`}
                        >
                          {newButton}
                        </div>
                      )}
                    />
                  ) : '' }
                </div>
              )}
            />
          </div>
        </div>
      </div>
    )
  }
}

CardPricingIndex.defaultProps = {
  theme: null,
  mot: '',
  hubs: [],
  itineraries: [],
  allNumPages: {},
  scope: null,
  toggleCreator: null
}

export default withNamespaces(['admin', 'common'])(CardPricingIndex)
