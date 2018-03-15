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
      theme, shipmentData, shipmentDispatch, user
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
              <div className={` ${styles.thank_you} flex-100 layout-row layout-align-start`}>
                <p className="flex-100">
                  Thank you for your booking request.
                </p>
              </div>
              <div className={`${styles.b_ref} flex-100 layout-row layout-align-start`}>
                Booking Reference: {shipment.imc_reference}
              </div>
              <div className={`flex-100 layout-row layout-align-start layout-wrap ${styles.thank_details}`}>
                <p className="flex-100">
                  Booking request confirmation has been sent to your account email address.
                  <br />
                  Please note that the rates can be changed withyout prior notice.
                  <br />
                  Your booking will be confirmed after a review.
                  <br />
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
                  handleNext={() => shipmentDispatch.toDashboard(user.id)}
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
  setStage: PropTypes.func.isRequired,
  user: PropTypes.objectOf(PropTypes.any)
}
ShipmentThankYou.defaultProps = {
  theme: PropTypes.objectOf(PropTypes.any),
  shipmentData: PropTypes.objectOf(PropTypes.any),
  shipmentDispatch: null,
  user: {}
}
export default ShipmentThankYou
