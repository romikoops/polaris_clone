import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { history } from '../../helpers'
import { RoundButton } from '../RoundButton/RoundButton'

export class AdminTruckingView extends Component {
  static backToIndex () {
    history.goBack()
  }

  constructor (props) {
    super(props)
    this.state = {
      expander: {}
    }
    this.expandView = this.expandView.bind(this)
  }
  expandView (id) {
    this.setState({
      expander: {
        ...this.state.expander,
        [id]: !this.state.expander[id]
      }
    })
  }

  render () {
    const { theme, truckingDetail, hubHash } = this.props
    if (!truckingDetail) {
      return ''
    }
    const { expander } = this.state
    const { truckingHub, pricing } = truckingDetail
    // eslint-disable-next-line no-underscore-dangle
    const nexus = hubHash[truckingHub._id].location
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Back"
          handleNext={AdminTruckingView.backToIndex}
          iconClass="fa-chevron-left"
        />
      </div>
    )
    const CityCell = ({ rates }) => (
      <div
        key={v4()}
        className={`flex-100 layout-row layout-align-start-center layout-wrap ${
          styles.trucking_zip_row
        }`}
      >
        <div className="flex-100 layout-row layout-align-start-center">
          <div
            className={`flex-25 layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Min Weight</p>
            <p className="flex-100">{rates.min}</p>
          </div>
          <div
            className={`flex-25 layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Max Weight</p>
            <p className="flex-100">{rates.max}</p>
          </div>
          <div
            className={`flex-25 layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Per KG Rate</p>
            <p className="flex-100">{rates.value}</p>
          </div>
          <div
            className={`flex-25 layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>CBM Rate</p>
            <p className="flex-100">{rates.per_cbm_rate}</p>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <div
            className={`flex-25 layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Pickup Fee</p>
            <p className="flex-100">{rates.pickup_fee}</p>
          </div>
          <div
            className={`flex-25 layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Delivery Fee</p>
            <p className="flex-100">{rates.delivery_fee}</p>
          </div>
          <div
            className={`flex-25 layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Delivery ETA</p>
            <p className="flex-100">{rates.delivery_eta_in_days}</p>
          </div>
        </div>
      </div>
    )
    const ZipRow = ({ rates }) => (
      <div
        key={v4()}
        className={`flex-100 layout-row layout-align-start-center layout-wrap ${
          styles.trucking_zip_row
        }`}
      >
        <div className="flex-100 layout-row layout-align-start-center">
          <div
            className={`flex layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Min Weight</p>
            <p className="flex-100">{rates.min}</p>
          </div>
          <div
            className={`flex layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Max Weight</p>
            <p className="flex-100">{rates.max}</p>
          </div>
          <div
            className={`flex layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Per KG Rate</p>
            <p className="flex-100">{rates.value}</p>
          </div>
          <div
            className={`flex layout-row layout-align-start-center layout-wrap ${
              styles.trucking_cell
            }`}
          >
            <p className={`flex-100 ${styles.trucking_cell_label}`}>Min Charge</p>
            <p className="flex-100">{rates.min_value}</p>
          </div>
        </div>
      </div>
    )
    const CityView = ({
      pricingInstance, viewExpander, expandFn, panelStyle
    }) => (
      <div key={v4()} className="flex-100 layout-row layout-align-start-start layout-wrap">
        <div
          className={`flex-100 layout-row layout-align-start-center ${styles.trucking_header_card}`}
        >
          <div
            className={`flex layout-row layout-align-start-center layout-wrap ${
              styles.trucking_city_header
            }`}
          >
            <p className={`flex-100 ${styles.trucking_city_header_label}`}>City</p>
            <p className="flex-100">{pricingInstance.city}</p>
          </div>
          <div
            className={`flex layout-row layout-align-start-center layout-wrap ${
              styles.trucking_city_header
            }`}
          >
            <p className={`flex-100 ${styles.trucking_city_header_label}`}>Province</p>
            <p className="flex-100">{pricingInstance.province}</p>
          </div>
          <div
            className={`flex layout-row layout-align-start-center layout-wrap ${
              styles.trucking_city_header
            }`}
          >
            <p className={`flex-100 ${styles.trucking_city_header_label}`}>Currency</p>
            <p className="flex-100">{pricingInstance.currency}</p>
          </div>
          <div
            className={`flex-10 layout-row layout-align-center-center ${
              styles.trucking_city_header
            }`}
            onClick={() => expandFn(pricingInstance.city)}
          >
            {viewExpander[pricingInstance.city] ? (
              <i className="fa fa-chevron-up clip" style={textStyle} />
            ) : (
              <i className="fa fa-chevron-down clip" style={textStyle} />
            )}
          </div>
        </div>
        <div
          className={`flex-100 layout-row layout-align-start-center layout-wrap ${panelStyle} ${
            styles.trucking_panel
          }`}
        >
          {pricingInstance.rate_table.map(rate => <CityCell rates={rate} />)}
        </div>
      </div>
    )
    const ZipView = ({
      pricingInstance, viewExpander, expandFn, panelStyle
    }) => (
      <div
        key={v4()}
        className={`flex-100 layout-row layout-align-start-start layout-wrap ${
          styles.trucking_zip
        }`}
      >
        <div
          className={`flex-100 layout-row layout-align-start-center ${styles.trucking_header_card}`}
        >
          <div
            className={`flex layout-row layout-align-start-center ${styles.trucking_city_header}`}
          >
            <p className={`flex-50 ${styles.trucking_city_header_label}`}>Effective ZipCodes</p>
            <p className="flex-50">
              {pricingInstance.lower_zip} - {pricingInstance.upper_zip}
            </p>
          </div>
          <div
            className={`flex layout-row layout-align-start-center ${styles.trucking_city_header}`}
          >
            <p className={`flex-50 ${styles.trucking_city_header_label}`}>Currency</p>
            <p className="flex-50">{pricingInstance.currency}</p>
          </div>
          <div
            className={`flex-10 layout-row layout-align-center-center ${
              styles.trucking_city_header
            }`}
            onClick={() => expandFn(pricingInstance.lower_zip)}
          >
            {viewExpander[pricingInstance.lower_zip] ? (
              <i className="fa fa-chevron-up clip" style={textStyle} />
            ) : (
              <i className="fa fa-chevron-down clip" style={textStyle} />
            )}
          </div>
        </div>
        <div
          className={`flex-100 layout-row layout-align-start-center layout-wrap ${panelStyle} ${
            styles.trucking_panel
          }`}
        >
          {pricingInstance.rate_table.map(rate => <ZipRow rates={rate} />)}
        </div>
      </div>
    )

    const allCities = pricing.data.map(pi => (
      <CityView
        pricingInstance={pi}
        viewExpander={expander}
        expandFn={this.expandView}
        panelStyle={expander[pi.city] ? styles.trucking_expanded : styles.trucking_closed}
      />
    ))
    const allZips = pricing.data.map(pi => (
      <ZipView
        pricingInstance={pi}
        viewExpander={expander}
        expandFn={this.expandView}
        panelStyle={expander[pi.lower_zip] ? styles.trucking_expanded : styles.trucking_closed}
      />
    ))
    const truckView = truckingHub.type === 'city' ? allCities : allZips

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {nexus.name}
          </p>
          {backButton}
        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Rates </p>
          </div>
          <div className="flex-100 layout-row layout-align-space-around-start layout-wrap">
            {truckView}
          </div>
        </div>
      </div>
    )
  }
}
AdminTruckingView.propTypes = {
  theme: PropTypes.theme,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  truckingDetail: PropTypes.shape({
    truckingHub: PropTypes.object,
    pricing: PropTypes.object
  })
}

AdminTruckingView.defaultProps = {
  theme: null,
  hubHash: null,
  truckingDetail: null
}

export default AdminTruckingView
