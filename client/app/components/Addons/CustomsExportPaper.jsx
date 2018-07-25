import React, { PureComponent } from 'react'
import PropTypes from '../../prop-types'
import styles from '../CargoDetails/CargoDetails.scss'
import { TextHeading } from '../TextHeading/TextHeading'
import { Checkbox } from '../Checkbox/Checkbox'

class CustomsExportPaper extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      addonView: false
    }
  }
  toggleAddon (bool) {
    this.setState({ addonView: bool }, () => this.props.toggleCustomAddon('customs_export_paper'))
  }
  render () {
    const { tenant, addon } = this.props
    const charge = addon.fees.total
    const { theme } = tenant.data
    const acceptedBox = (
      <div
        className={`flex-100 layout-row layout-wrap ${styles.customs_box}  ${styles.box_content} ${
          this.state.addonView ? styles.show : styles.hidden
        }`}
      >
        <div className="flex-80 layout-row layout-wrap">
          <p className="flex-90">
            <strong>
              {' '}
              When you ship goods from Germany the Customs Export Paper is required to pass through customs
            </strong>
          </p>
          <p className="flex-90">
            {`${tenant.data.name} will orgnaise the ADB on your behalf. Initially
              ${charge.currency} ${Number(charge.value).toFixed(2)} will be
              added to your booking. Additional Customs Export Papers will be charged as
              needed at ${charge.currency} 12.50 per paper`}
          </p>
        </div>
        <div
          className={` ${styles.prices} flex-20 layout-row layout-wrap layout-align-start-start`}
        >
          <div className={`${styles.customs_total} flex-100 layout-row  layout-align-end-center`}>
            <p className="flex-none">Total</p>
            <h6 className="flex-none center">
              {' '}
              {charge.currency} {Number(charge.value).toFixed(2)}
            </h6>
          </div>
        </div>
      </div>
    )

    const declinedBox = (
      <div
        className={`flex-100 layout-row layout-align-start-center layout-wrap ${
          styles.no_customs_box
        } ${!this.state.addonView ? styles.show : ''}`}
      >
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <p className="flex-100">
            <b>
              {`A Customs Export Paper (ADB) is mandatory for all shipments when exporting from Germany. If you choose to secure your Customs Export Paper on your own, ${
                tenant.data.name
              }
              will need a copy of the Customs Export Paper.`}
            </b>
          </p>
        </div>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-align-center padd_top">
        <div
          className="flex-none content_width layout-row layout-wrap section_padding"
        >
          <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
            <div className="flex-none layout-row layout-align-space-around-center">
              <TextHeading theme={theme} size={2} text="Customs Export Paper" />
            </div>

            <div
              className="flex-33 layout-wrap layout-row layout-align-space-around-center"
            >
              <div className="flex-100 layout-row layout-align-end-center">
                <div className="flex-90 layout-row layout-align-start-center">
                  <p className="flex-none" style={{ marginRight: '5px' }}>
                    {`Yes, I want ${tenant.data.name} to secure my Customs Export Paper (ADB)`}
                  </p>
                </div>
                <div className="flex-10 layout-row layout-align-end-center">
                  <Checkbox
                    onChange={() => this.toggleAddon(true)}
                    checked={this.state.addonView}
                    theme={theme}
                  />
                </div>
              </div>
              <div className="flex-100 layout-row layout-align-end-center">
                <div className="flex-90 layout-row layout-align-start-center">
                  <p className="flex-none" style={{ marginRight: '5px' }}>
                    {`No, I do not want ${tenant.data.name} to secure my Customs Export Paper (ADB)`}
                  </p>
                </div>
                <div className="flex-10 layout-row layout-align-end-center">
                  <Checkbox
                    onChange={() => this.toggleAddon(false)}
                    checked={
                      this.state.addonView === null ? null : !this.state.addonView
                    }
                    theme={theme}
                  />
                </div>
              </div>
            </div>
          </div>
          {acceptedBox}
          {declinedBox}
        </div>
      </div>
    )
  }
}

CustomsExportPaper.propTypes = {
  tenant: PropTypes.tenant,
  addon: PropTypes.objectOf(PropTypes.any),
  toggleCustomAddon: PropTypes.func
}
CustomsExportPaper.defaultProps = {
  tenant: {},
  addon: {},
  toggleCustomAddon: false
}

export default CustomsExportPaper
