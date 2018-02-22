import React, { Component } from 'react'
import Truncate from 'react-truncate'
import PropTypes from '../../prop-types'
import styles from './CargoDetails.scss'
import { Checkbox } from '../Checkbox/Checkbox'
import FileUploader from '../FileUploader/FileUploader'
import { HSCodeRow } from '../HSCodeRow/HSCodeRow'
import defaults from '../../styles/default_classes.scss'
import { converter } from '../../helpers'
import { Tooltip } from '../Tooltip/Tooltip'
import FormsyInput from '../FormsyInput/FormsyInput'
import { TextHeading } from '../TextHeading/TextHeading'

export class CargoDetails extends Component {
  constructor (props) {
    super(props)
    this.state = {
      insuranceView: false,
      customsView: false
    }
    this.toggleInsurance = this.toggleInsurance.bind(this)
    this.toggleCustoms = this.toggleCustoms.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.fileFn = this.fileFn.bind(this)
    this.calcCustomsFee = this.calcCustomsFee.bind(this)
  }
  toggleInsurance () {
    this.setState({ insuranceView: !this.state.insuranceView })
    // this.props.handleInsurance();
  }
  toggleCustoms () {
    const { setCustomsFee, customsData } = this.props
    this.setState({ customsView: !this.state.customsView })
    // this.timeoutId = setTimeout(function() {
    this.setState({ showNoCustoms: this.state.customsView })
    const converted = this.calcCustomsFee()
    const resp = converted === 0 ? { bool: false, val: 0 } : { bool: true, val: converted }
    if (customsData && customsData.val && customsData.val !== converted) {
      setCustomsFee(resp)
    }
  }
  deleteDoc (key) {
    const { shipmentData, shipmentDispatch } = this.props
    const { documents } = shipmentData
    const { id } = documents[key]
    shipmentDispatch.deleteDocument(id)
  }
  fileFn (file) {
    const { shipmentData, shipmentDispatch } = this.props
    const { shipment } = shipmentData
    const type = file.doc_type
    const url = `/shipments/${shipment.id}/upload/${type}`
    shipmentDispatch.uploadDocument(file, type, url)
  }

  calcCustomsFee () {
    const {
      hsCodes, shipmentData, currencies, tenant, hsTexts
    } = this.props
    const { customs, cargoItems, containers } = shipmentData
    if (tenant && tenant.data.scope.cargo_info_level === 'text') {
      let hsCount = 0
      cargoItems.forEach((ci) => {
        if (hsTexts[ci.cargo_group_id]) {
          hsCount += 1
        }
      })
      containers.forEach((cn) => {
        if (hsTexts[cn.cargo_group_id]) {
          hsCount += 1
        }
      })
      if (!customs) {
        return 200
      }
      if (hsCount > customs.limit) {
        const diff = hsCount - customs.limit
        return customs.fee + diff * customs.extra
      }
    } else {
      let hsCount = 0
      cargoItems.forEach((ci) => {
        if (hsCodes[ci.cargo_group_id]) {
          hsCount += hsCodes[ci.cargo_group_id].length
        }
      })
      containers.forEach((cn) => {
        if (hsCodes[cn.cargo_group_id]) {
          hsCount += hsCodes[cn.cargo_group_id].length
        }
      })
      if (!customs) {
        return 200
      }
      if (hsCount > customs.limit) {
        const diff = hsCount - customs.limit
        return customs.fee + diff * customs.extra
      }
    }
    const converted = converter(customs.fee, customs.currency, currencies).toFixed(2)
    return converted
  }
  handleChange (event) {
    this.props.handleChange(event)
  }
  render () {
    const {
      shipmentData,
      theme,
      insurance,
      hsCodes,
      hsTexts,
      handleHsTextChange,
      setHsCode,
      deleteCode,
      user,
      tenant
    } = this.props
    const {
      dangerousGoods, documents, customs, cargoItems, containers
    } = shipmentData
    const DocViewer = ({ doc }) => (
      <div className="flex-100 layout-row layout-align-start-center">
        <p className={`flex-80 ${styles.doc_title}`}>
          <Truncate lines={1}>{doc.text} </Truncate>
        </p>
        <div
          className="flex-20 layout-row layout-align-center-center"
          onClick={() => this.deleteDoc(doc.doc_type)}
        >
          <i className="fa fa-trash" />
        </div>
      </div>
    )
    const insuranceBox = (
      <div
        className={`flex-100 layout-row  ${styles.box_content} ${
          this.state.insuranceView ? styles.show : ''
        }`}
      >
        <div className="flex-80 layout-row layout-wrap">
          <p className="flex-90">
            <strong>
              {' '}
              Sign an insurance for the replacement of the goods shipped in case of total or partial
              loss or damage. The price of the insurance will be determined by the goods value and
              the transport charges.
            </strong>
          </p>
          <p className="flex-90">
            Note that if you choose not to pay to insure your shipment, the goods shipped are
            automatically covered under legal liability standard to the transportation industry.
          </p>
        </div>
        <div className={` ${styles.prices} flex-20 layout-row layout-wrap`}>
          <h5 className="flex-100"> Price </h5>
          <h6 className="flex-100">
            {' '}
            {insurance.val.toFixed(2)} {user.currency}
          </h6>
        </div>
      </div>
    )
    const customsBox = (
      <div
        className={`flex-100 layout-row layout-wrap  ${styles.box_content} ${
          this.state.customsView ? styles.show : styles.hidden
        }`}
      >
        <div className="flex-80 layout-row layout-wrap">
          <p className="flex-90">
            <strong>
              {' '}
              When you ship goods from outside the European Union (EU), you may be charged customs
              duty and/or VAT. You can either handle the customs on your own, or have Greencarrier
              handle it for you.
            </strong>
          </p>
          <p className="flex-90">
            To cover our costs when we present your goods to the customs authorities – and pay any
            customs duty or VAT due on your behalf – we charge a clearance / handling fee. The fee
            depends on the value of the goods you are shipping, and can be found here to the right.
          </p>
        </div>
        <div className={` ${styles.prices} flex-20 layout-row layout-wrap`}>
          <h5 className="flex-100"> Price </h5>
          <h6 className="flex-100">
            {' '}
            {customs ? this.calcCustomsFee() : '18.50'} {user.currency}
          </h6>
        </div>
        <HSCodeRow
          className="flex-100"
          containers={containers}
          cargoItems={cargoItems}
          theme={theme}
          tenant={tenant}
          setCode={setHsCode}
          handleHsTextChange={handleHsTextChange}
          deleteCode={deleteCode}
          hsCodes={hsCodes}
          hsTexts={hsTexts}
        />
      </div>
    )
    const noCustomsBox = (
      <div
        className={`flex-100 layout-row layout-align-start-center ${styles.no_customs_box} ${
          this.state.showNoCustoms ? styles.show : ''
        }`}
      >
        <div className="flex-33 no_max layout-row layout-align-center-center">
          <div className="flex-90 layout-row layout-wrap">
            <div className="flex-100">
              <p className={`flex-none ${styles.f_header}`}> Customs Declaration</p>
            </div>
            <div className="flex-100">
              {documents.customs_declaration ? (
                <DocViewer doc={documents.customs_declaration} />
              ) : (
                <FileUploader
                  theme={theme}
                  dispatchFn={this.fileFn}
                  type="customs_declaration"
                  text="Customs Declaration"
                />
              )}
            </div>
          </div>
        </div>
        <div className="flex-33 no_max layout-row layout-align-center-center">
          {this.props.totalGoodsValue > 20000 ? (
            <div className="flex-90 layout-row layout-wrap">
              <div className="flex-100">
                <p className={`flex-none ${styles.f_header}`}> Customs Value Declaration</p>
              </div>
              <div className="flex-100">
                {documents.customs_value_declaration ? (
                  <DocViewer doc={documents.customs_value_declaration} />
                ) : (
                  <FileUploader
                    theme={theme}
                    dispatchFn={this.fileFn}
                    type="customs_value_declaration"
                    text="Customs Value Declaration"
                  />
                )}
              </div>
            </div>
          ) : (
            ''
          )}
        </div>
        <div className="flex-33 no_max layout-row layout-align-center-center">
          <div className="flex-90 layout-row layout-wrap">
            <div className="flex-100">
              <p className={`flex-none ${styles.f_header}`}> EORI</p>
            </div>
            <div className="flex-100">
              {documents.eori ? (
                <DocViewer doc={documents.eori} />
              ) : (
                <FileUploader theme={theme} dispatchFn={this.fileFn} type="eori" text="EORI" />
              )}
            </div>
          </div>
        </div>
      </div>
    )
    return (
      <div className="flex-100 layout-row layout-wrap padd_top">
        <div className="flex-100 layout-row layout-align-center">
          <div className={`flex-none ${defaults.content_width} layout-row layout-wrap`}>
            <div className="flex-100 layout-row">
              <div className="flex-none">
                <TextHeading theme={theme} size={2} text="Cargo Details" />
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap">
              <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap
                  layout-align-start-start"
              >
                <div className="flex-100 layout-row layout-wrap">
                  <div className="flex-100">
                    {' '}
                    <div className="flex-none">
                      <TextHeading theme={theme} size={3} text="Total valued goods" />
                    </div>
                  </div>
                  <div className="flex-100">
                    <FormsyInput
                      className={styles.cargo_input}
                      wrapperClassName={styles.wrapper_cargo_input}
                      errorMessageStyles={{
                        fontSize: '13px',
                        bottom: '-17px'
                      }}
                      type="number"
                      name="totalGoodsValue"
                      onChange={this.handleChange}
                      submitAttempted={this.props.finishBookingAttempted}
                      validations={{ nonNegative: (values, value) => value > 0 }}
                      validationErrors={{
                        nonNegative: 'Must be greater than 0',
                        isDefaultRequiredValue: 'Must be greater than 0'
                      }}
                      required
                    />
                  </div>
                </div>
                <div className="flex-100 layout-row layout-wrap">
                  <div className="flex-100">
                    <div className={`flex-none ${styles.f_header}`}>
                      {' '}
                      <TextHeading
                        theme={theme}
                        size={3}
                        text="Number and kind of packages, description of goods (optional)"
                      />
                    </div>
                  </div>
                  <div className="flex-100">
                    <textarea
                      className={styles.cargo_text_area}
                      rows="6"
                      name="cargoNotes"
                      value={this.props.cargoNotes}
                      onChange={this.handleChange}
                    />
                  </div>
                </div>
              </div>
              <div className="flex-100 flex-gt-sm-45 offset-gt-sm-5
                  layout-row layout-wrap alyout-align-start-start"
              >
                <div className="flex-100 layout-row">
                  <div className={`flex-none ${styles.f_header}`}>
                    <TextHeading theme={theme} size={3} text="Required Documents" />
                  </div>
                </div>

                <div className="flex-50 layout-row layout-wrap">
                  <div className="flex-100">
                    <div className={`flex-none ${styles.f_header}`}>
                      {' '}
                      <TextHeading theme={theme} size={3} text="Packing Sheet" />
                    </div>
                  </div>
                  <div className="flex-100">
                    {documents.packing_sheet ? (
                      <DocViewer doc={documents.packing_sheet} />
                    ) : (
                      <FileUploader
                        theme={theme}
                        type="packing_sheet"
                        dispatchFn={this.fileFn}
                        text="Packing Sheet"
                      />
                    )}
                  </div>
                </div>

                <div className="flex-50 layout-row layout-wrap">
                  <div className="flex-100">
                    <div className={`flex-none ${styles.f_header}`}>
                      {' '}
                      <TextHeading theme={theme} size={3} text="Commercial Invoice" />
                    </div>
                  </div>
                  <div className="flex-100">
                    {documents.commercial_invoice ? (
                      <DocViewer doc={documents.commercial_invoice} />
                    ) : (
                      <FileUploader
                        theme={theme}
                        type="commercial_invoice"
                        dispatchFn={this.fileFn}
                        text="Commercial Invoice"
                      />
                    )}
                  </div>
                </div>

                <div className="flex-50 layout-row layout-wrap">
                  <div className="flex-100 layout-row">
                    <div className="flex-none">
                      {' '}
                      <TextHeading theme={theme} size={3} text="Certificate of Origin" />
                    </div>
                  </div>
                  <div className="flex-100">
                    {documents.certificate_of_origin ? (
                      <DocViewer doc={documents.certificate_of_origin} />
                    ) : (
                      <FileUploader
                        theme={theme}
                        type="certificate_of_origin"
                        dispatchFn={this.fileFn}
                        text="Certificate of Origin"
                      />
                    )}
                  </div>
                </div>
                {dangerousGoods ? (
                  <div className="flex-50 layout-row layout-wrap">
                    <div className="flex-100">
                      <div className={`flex-none ${styles.f_header}`}>
                        {' '}
                        <TextHeading theme={theme} size={3} text="Dangerouus Goods Declaration" />
                      </div>
                    </div>
                    <div className="flex-100">
                      {documents.dangerous_goods ? (
                        <DocViewer doc={documents.dangerous_goods} />
                      ) : (
                        <FileUploader
                          theme={theme}
                          type="dangerous_goods"
                          dispatchFn={this.fileFn}
                          text="Dangerous Goods Declaration"
                        />
                      )}
                    </div>
                  </div>
                ) : (
                  ''
                )}
              </div>
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-center padd_top">
          <div
            className={`flex-none ${defaults.content_width} layout-row layout-wrap section_padding`}
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex-none">
                <TextHeading theme={theme} size={2} text="Insurance" />
              </div>
              <Tooltip theme={theme} icon="fa-info-circle" text="insurance" />
              <Checkbox
                onChange={this.toggleInsurance}
                checked={this.state.insuranceView}
                theme={theme}
              />
            </div>
            {insuranceBox}
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-center padd_top">
          <div
            className={`flex-none ${defaults.content_width} layout-row layout-wrap section_padding`}
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex-none">
                <TextHeading theme={theme} size={2} text="Customs Handling Fee" />
              </div>
              <Tooltip theme={theme} icon="fa-info-circle" text="customs_clearance" />
              <Checkbox
                onChange={this.toggleCustoms}
                checked={this.state.customsView}
                theme={theme}
              />
            </div>
            {customsBox}
            {noCustomsBox}
          </div>
        </div>
      </div>
    )
  }
}
CargoDetails.propTypes = {
  theme: PropTypes.theme,
  tenant: PropTypes.objectOf(PropTypes.any),
  shipmentData: PropTypes.shipmentData.isRequired,
  handleChange: PropTypes.func.isRequired,
  cargoNotes: PropTypes.string.isRequired,
  totalGoodsValue: PropTypes.number.isRequired,
  insurance: PropTypes.shape({
    val: PropTypes.any
  }).isRequired,
  customsData: PropTypes.shape({
    val: PropTypes.any
  }).isRequired,
  setCustomsFee: PropTypes.func.isRequired,
  shipmentDispatch: PropTypes.shape({
    deleteDocument: PropTypes.func,
    uploadDocument: PropTypes.func
  }).isRequired,
  user: PropTypes.user.isRequired,
  deleteCode: PropTypes.func.isRequired,
  setHsCode: PropTypes.func.isRequired,
  currencies: PropTypes.arrayOf(PropTypes.shape({
    key: PropTypes.string,
    rate: PropTypes.number
  })).isRequired,
  hsCodes: PropTypes.arrayOf(PropTypes.string).isRequired,
  finishBookingAttempted: PropTypes.bool,
  hsTexts: PropTypes.objectOf(PropTypes.string),
  handleHsTextChange: PropTypes.func
}

CargoDetails.defaultProps = {
  theme: null,
  tenant: null,
  finishBookingAttempted: false,
  hsTexts: {},
  handleHsTextChange: null
}

export default CargoDetails
