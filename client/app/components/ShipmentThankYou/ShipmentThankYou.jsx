import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './ShipmentThankYou.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import defaults from '../../styles/default_classes.scss'

export class ShipmentThankYou extends Component {
  componentDidMount () {
    const { setStage } = this.props
    setStage(6)
    window.scrollTo(0, 0)
  }
  render () {
    const {
      theme, shipmentData, shipmentDispatch
    } = this.props
    if (!shipmentData) return <h1>Loading</h1>
    const {
      shipment
    } = shipmentData
    if (!shipment) return <h1> Loading</h1>
    return (
      <div className="flex-100 layout-row layout-wrap">
        <div className="flex-100 layout-row layout-wrap layout-align-center">
          <div className={`${defaults.content_width} flex-none  layout-row layout-wrap layout-align-start`}>
            <div className={` ${styles.thank_box} flex-100 layout-row layout-wrap`}>
              <div className={` ${styles.thank_you} flex-100 layout-row layout-wrap layout-align-start`}>
                <p className="flex-100">
                  Thank you for your booking request.
                </p>
              </div>
              <div className={`flex-100 layout-row layout-align-start ${styles.b_ref}`}>
                <p className="flex-100">Booking Reference: {shipment.imc_reference}</p>
              </div>
              <div className={`flex-100 layout-row layout-align-start layout-wrap ${styles.thank_details}`}>
                <p className="flex-100">
                  Booking request confirmation has been sent to your account email address.
                </p>
                <p className="flex-100">
                  Please note that the rates can be changed withyout prior notice.
                </p>
                <p className="flex-100">
                  Your booking will be confirmed after a review.
                </p>
                <p className="flex-100">
                  Do not hesitate to contact us either through the
                  message center or your account manager
                </p>
              </div>
            </div>

            <hr className={`${styles.sec_break} flex-100`} />
            <div className={`${styles.back_to_dash_sec} flex-100 layout-row layout-wrap layout-align-center`}>
              <div className={`${defaults.content_width} flex-none content-width layout-row layout-align-start-center`}>
                <RoundButton
                  theme={theme}
                  text="Back to dashboard"
                  back
                  iconClass="fa-angle0-left"
                  handleNext={() => shipmentDispatch.toDashboard()}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
ShipmentThankYou.propTypes = {
  theme: PropTypes.objectOf(PropTypes.any),
  shipmentData: PropTypes.objectOf(PropTypes.any),
  shipmentDispatch: PropTypes.objectOf(PropTypes.any),
  setStage: PropTypes.func.isRequired
}
ShipmentThankYou.defaultProps = {
  theme: PropTypes.objectOf(PropTypes.any),
  shipmentData: PropTypes.objectOf(PropTypes.any),
  shipmentDispatch: null
}
export default ShipmentThankYou
