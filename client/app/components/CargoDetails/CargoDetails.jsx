import React, { Component } from 'react'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../prop-types'
import styles from './CargoDetails.scss'
import { Checkbox } from '../Checkbox/Checkbox'
import DocumentsForm from '../Documents/Form'
import DocumentsMultiForm from '../Documents/MultiForm'
// import { HSCodeRow } from '../HSCodeRow/HSCodeRow'
import defaults from '../../styles/default_classes.scss'
import { converter } from '../../helpers'
import { currencyOptions, tooltips } from '../../constants'
import FormsyInput from '../FormsyInput/FormsyInput'
import { TextHeading } from '../TextHeading/TextHeading'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import { Tooltip } from '../Tooltip/Tooltip'

export class CargoDetails extends Component {
  static displayCustomsFee (customsData, target, customs) {
    if (target === 'total') {
      let newTotal = 0
      if (customsData.import.bool) {
        newTotal += parseFloat(customs.import.total.value)
      }
      if (customsData.export.bool) {
        newTotal += parseFloat(customs.export.total.value)
      }
      return `${newTotal.toFixed(2)} ${customs.total.total.currency}`
    }
    if (customsData[target].bool) {
      if (customs) {
        const fee = customs[target]
        if (fee && !fee.unknown && fee.total.value) {
          return `${parseFloat(fee.total.value).toFixed(2)} ${fee.total.currency}`
        }
        return 'Price subject to local regulations'
      }
    }
    if (customs.import.total.currency) {
      const { currency } = customs.import.total
      return `0 ${currency}`
    } else if (customs.export.total.currency) {
      const { currency } = customs.export.total
      return `0 ${currency}`
    }
    return '0 EUR'
  }
  constructor (props) {
    super(props)
    this.state = {
      insuranceView: null,
      customsView: null,
      totalGoodsCurrency: { value: 'EUR', label: 'EUR' }
    }

    this.handleChange = this.handleChange.bind(this)
    this.handleTotalGoodsCurrency = this.handleTotalGoodsCurrency.bind(this)
    this.fileFn = this.fileFn.bind(this)
    this.deleteDoc = this.deleteDoc.bind(this)
    this.calcCustomsFee = this.calcCustomsFee.bind(this)
  }
  toggleInsurance (bool) {
    this.setState({ insuranceView: bool })
    this.props.handleInsurance(bool)
  }
  toggleCustoms (bool) {
    this.setState({ customsView: bool })
  }
  toggleSpecificCustoms (target) {
    const { setCustomsFee, customsData, shipmentData } = this.props
    const { customs } = shipmentData

    const converted = customs[target].unknown ? 0 : customs[target].total.value
    const resp = customsData[target].bool
      ? { bool: false, val: 0 }
      : {
        bool: true,
        val: converted,
        currency: customs[target].unknown ? 'EUR' : customs[target].total.currency
      }

    // if (customsData && customsData[target].val && customsData[target].val !== converted) {
    setCustomsFee(target, resp)
    // }
  }
  deleteDoc (doc) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.deleteDocument(doc.id)
  }
  fileFn (file) {
    const { shipmentData, shipmentDispatch } = this.props
    const { shipment } = shipmentData
    const type = file.doc_type
    const url = `/shipments/${shipment.id}/upload/${type}`
    shipmentDispatch.uploadDocument(file, type, url)
  }

  calcCustomsFee (target) {
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
  handleTotalGoodsCurrency (selection) {
    this.setState({ totalGoodsCurrency: selection })
    this.props.handleTotalGoodsCurrency(selection.value)
  }
  render () {
    const {
      shipmentData,
      theme,
      // insurance,
      // hsCodes,
      // hsTexts,
      // handleHsTextChange,
      // setHsCode,
      // deleteCode,
      customsData,
      finishBookingAttempted,
      tenant,
      eori
    } = this.props
    const { totalGoodsCurrency } = this.state
    const { scope } = tenant.data
    const {
      dangerousGoods, documents, shipment, customs
    } = shipmentData
    const insuranceBox = (
      <div
        className={`flex-100 layout-row  ${styles.box_content} ${
          this.props.insurance.bool ? styles.show : ''
        }`}
      >
        <div className="flex-80 layout-row layout-wrap">
          <p className="flex-90">
            <strong>
              {' '}
              A cost effective and simple way to cover for physical loss or damage to goods in
              transit.
            </strong>
          </p>
          <p className="flex-90">
            How insurance premium is calculated:
            <br />
            <br />
            Basis of premium calculation CIF + 10% X the actual premium rate (The actual premium
            rate applied on the total sum of cost of goods + freight + 10% margin)
            <br />
            <br />
            Please contact your local Greencarrier office for more info.
          </p>
        </div>
        {/* <div className={` ${styles.prices} flex-20
          layout-row layout-wrap layout-align-start-start`}>
          <div
            className={`${styles.customs_prices} flex-100 layout-row  layout-align-end-center`}
          >
            <p className="flex-none end">Insurance Price</p>
            <h6 className="flex-none end">
              {' '}
              {insurance.val.toFixed(2)} {user.currency}
            </h6>
          </div>
        </div> */}
      </div>
    )
    const fadedPreCarriageText = shipment.has_pre_carriage ? '' : styles.faded_text
    const fadedOnCarriageText = shipment.has_on_carriage ? '' : styles.faded_text

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
          <div className="flex-100 layout-row layout-align-start-start">
            <div className="flex-100 layout-row layout-align-start-center">
              <p className="flex-none"> {`I would like ${tenant.data.name} to handle:`}</p>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
              <div
                className="flex-50 layout-row layout-align-space-around-center"
                data-tip={tooltips.customs_pre_carriage}
                data-for="preCarriageTooltip"
              >
                <p className={`${fadedPreCarriageText} flex-none`}> Export Customs: </p>
                <Checkbox
                  onChange={() => this.toggleSpecificCustoms('export')}
                  checked={customsData.export.bool}
                  theme={theme}
                  disabled={!shipment.has_pre_carriage}
                />
              </div>
              {!shipment.has_pre_carriage ? (
                <ReactTooltip
                  id="preCarriageTooltip"
                  className={styles.tooltip_box}
                  effect="solid"
                />
              ) : (
                ''
              )}
              <div
                className="flex-50 layout-row layout-align-space-around-center"
                data-tip={tooltips.customs_on_carriage}
                data-for="onCarriageTooltip"
              >
                <p className={`${fadedOnCarriageText} flex-none`}> Import Customs</p>
                <Checkbox
                  onChange={() => this.toggleSpecificCustoms('import')}
                  checked={customsData.import.bool}
                  theme={theme}
                  disabled={!shipment.has_on_carriage}
                />
                {!shipment.has_on_carriage ? (
                  <ReactTooltip
                    id="onCarriageTooltip"
                    className={styles.tooltip_box}
                    effect="solid"
                  />
                ) : (
                  ''
                )}
              </div>
            </div>
          </div>
        </div>
        <div
          className={` ${styles.prices} flex-20 layout-row layout-wrap layout-align-start-start`}
        >
          <div className={`${styles.customs_prices} flex-100 layout-row  layout-align-end-center`}>
            <p className="flex-none">Import</p>
            <h6 className="flex-none center">
              {' '}
              {CargoDetails.displayCustomsFee(customsData, 'import', customs)}
            </h6>
          </div>
          <div className={`${styles.customs_prices} flex-100 layout-row  layout-align-end-center`}>
            <p className="flex-none">Export</p>
            <h6 className="flex-none center">
              {' '}
              {CargoDetails.displayCustomsFee(customsData, 'export', customs)}
            </h6>
          </div>

          <div className={`${styles.customs_total} flex-100 layout-row  layout-align-end-center`}>
            <p className="flex-none">Total</p>
            <h6 className="flex-none center">
              {' '}
              {CargoDetails.displayCustomsFee(customsData, 'total', customs)}
            </h6>
          </div>
        </div>
      </div>
    )
    const textComp = (
      <b style={{ 'font-weight': 'normal', 'font-size': '.83em' }}>(if applicable)</b>
    )
    const noCustomsBox = (
      <div
        className={`flex-100 layout-row layout-align-start-center ${styles.no_customs_box} ${
          !this.state.customsView ? styles.show : ''
        }`}
      >
        <div className="flex-33 no_max layout-row layout-align-start-center">
          <div className="flex-90 layout-row layout-wrap">
            <div className="flex-100">
              <TextHeading theme={theme} size={3} text="EORI" Comp={textComp} />
            </div>
            <div className="flex-100 input_box">
              <input
                className={styles.EORI_input}
                type="text"
                name="eori"
                value={eori}
                onChange={this.handleChange}
                placeholder="Type in EORI number"
              />
            </div>
          </div>
        </div>
        <div className="flex-33 no_max layout-row layout-align-start-center">
          <div className="flex-90 layout-row layout-wrap">
            <div className="flex-100">
              <TextHeading theme={theme} size={3} text="Customs Declaration" />
            </div>
            <div className="flex-100 layout-row layout-wrap" name="customs_declaration">
              <div className="flex-100 layout-row layout-wrap" name="customs_declaration">
                <div className="flex-100 layout-row">
                  <DocumentsForm
                    theme={theme}
                    type="customs_declaration"
                    dispatchFn={this.fileFn}
                    text="Customs decl."
                    doc={documents.customs_declaration}
                    isRequired
                    deleteFn={this.deleteDoc}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="flex-33 no_max layout-row layout-align-end-center">
          {this.props.totalGoodsValue.value > 20000 ? (
            <div className="flex-90 layout-row layout-wrap">
              <div className="flex-100">
                <TextHeading theme={theme} size={3} text="Customs Value Declaration" />
              </div>
              <div className="flex-100 layout-row layout-wrap" name="customs_value_declaration">
                <div className="flex-100 layout-row">
                  <DocumentsForm
                    theme={theme}
                    type="customs_value_declaration"
                    text="Customs Val. Decl."
                    dispatchFn={this.fileFn}
                    doc={documents.customs_declaration}
                    isRequired
                    deleteFn={this.deleteDoc}
                  />
                </div>
              </div>
            </div>
          ) : (
            ''
          )}
        </div>
      </div>
    )

    return (
      <div name="cargoDetailsBox" className="flex-100 layout-row layout-wrap padd_top">
        <div className="flex-100 layout-row layout-align-center">
          <div className={`flex-none ${defaults.content_width} layout-row layout-wrap`}>
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div className="flex-45 layout-align-start-center layout-row">
                <div className="flex-none">
                  <TextHeading theme={theme} size={2} text="Cargo Details" />
                </div>
              </div>
              <div className="flex-45 layout-align-start-center layout-row">
                <div className="flex-none">
                  <TextHeading theme={theme} size={2} text="Shipment Documents " />
                </div>
                <div className="flex-none" style={{ marginLeft: '10px' }}>
                  <p className="flex-none">( if available )</p>
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap">
              <div className="flex-100">
                {' '}
                <div className="flex-none">
                  <TextHeading theme={theme} size={3} text="Total value of goods" />
                </div>
              </div>
              <div
                className="flex-100 flex-gt-sm-50 layout-row layout-wrap
                  layout-align-start-start"
              >
                <div className="flex-100 layout-row layout-wrap">
                  <div className="flex-100 layout-row">
                    <div className="flex-66 layout-row">
                      <FormsyInput
                        className={`flex-100 ${styles.cargo_input} `}
                        wrapperClassName={`flex-100 ${styles.wrapper_cargo_input}`}
                        errorMessageStyles={{
                          fontSize: '13px',
                          bottom: '-17px'
                        }}
                        type="number"
                        name="totalGoodsValue"
                        onChange={this.handleChange}
                        submitAttempted={finishBookingAttempted}
                        validations={{ nonNegative: (values, value) => value > 0 }}
                        validationErrors={{
                          nonNegative: 'Must be greater than 0',
                          isDefaultRequiredValue: 'Must be greater than 0'
                        }}
                        required
                      />
                    </div>
                    <div className="flex-33 layout-row">
                      <NamedSelect
                        className="flex-100"
                        options={currencyOptions}
                        onChange={this.handleTotalGoodsCurrency}
                        value={totalGoodsCurrency}
                        clearable={false}
                      />
                    </div>
                  </div>
                </div>
                <div className="flex-100 layout-row layout-wrap">
                  <div className="flex-100">
                    <div className={`flex-none ${styles.f_header}`}>
                      {' '}
                      <TextHeading theme={theme} size={3} text="Description of goods (optional)" />
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
                <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                  <div className="flex-100">
                    <div className={`flex-none ${styles.f_header}`}>
                      {' '}
                      <TextHeading theme={theme} size={3} text="Incoterm" />
                    </div>
                  </div>
                  <div className="flex-100 layout-row layout-align-start-start input_box_full">
                    <textarea
                      className={styles.textarea_incoterm}
                      name="incoterm"
                      id=""
                      cols="30"
                      rows="6"
                      value={this.props.incoterm}
                      onChange={this.props.handleChange}
                    />
                  </div>
                </div>
              </div>
              <div
                className="flex-100 flex-gt-sm-45 offset-gt-sm-5
                  layout-row layout-wrap layout-align-start-start"
              >
                <div className="flex-100 layout-row layout-wrap" name="packing_sheet">
                  <div className="flex-100 layout-row">
                    <DocumentsForm
                      theme={theme}
                      type="packing_sheet"
                      dispatchFn={this.fileFn}
                      text="Packing Sheet"
                      doc={documents.packing_sheet}
                      isRequired
                      deleteFn={this.deleteDoc}
                    />
                  </div>
                </div>

                <div className="flex-100 layout-row layout-wrap" name="commercial_invoice">
                  <div className="flex-100 layout-row">
                    <DocumentsForm
                      theme={theme}
                      type="commercial_invoice"
                      dispatchFn={this.fileFn}
                      text="Commercial Invoice"
                      doc={documents.commercial_invoice}
                      isRequired
                      deleteFn={this.deleteDoc}
                    />
                  </div>
                </div>
                {dangerousGoods ? (
                  <div className="flex-100 layout-row layout-wrap">
                    <div className="flex-100 layout-row layout-wrap">
                      <DocumentsForm
                        theme={theme}
                        type="dangerous_goods"
                        dispatchFn={this.fileFn}
                        text="Dangerous Goods"
                        doc={documents.dangerous_goods}
                        deleteFn={this.deleteDoc}
                      />
                    </div>
                  </div>
                ) : (
                  ''
                )}
                <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                  <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                    <div className="flex-100">
                      <div className={`flex-none ${styles.f_header}`}>
                        {' '}
                        <TextHeading theme={theme} size={3} text="Document Notes" />
                      </div>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-start input_box_full">
                      <textarea
                        className={styles.textarea_margin}
                        name="notes"
                        id=""
                        cols="30"
                        rows="6"
                        value={this.props.notes}
                        onChange={this.props.handleChange}
                      />
                    </div>
                  </div>
                  <div className="flex-gt-sm-100 layout-row layout-align-start-start layout-wrap">
                    <div
                      className="
                    flex-100 layout-row layout-align-start-start-space-around layout-wrap"
                    >
                      <DocumentsMultiForm
                        theme={theme}
                        type="miscellaneous"
                        dispatchFn={this.fileFn}
                        text="Miscellaneous"
                        documents={documents.miscellaneous}
                        deleteFn={this.deleteDoc}
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        {scope.has_customs || scope.has_insurance ? (
          <div
            className={
              `${styles.insurance_customs_sec} flex-100 ` +
              'layout-row layout-wrap layout-align-center'
            }
          >
            {scope.has_insurance ? (
              <div className="flex-100 layout-row layout-align-center padd_top">
                <div
                  className={`flex-none ${
                    defaults.content_width
                  } layout-row layout-wrap section_padding`}
                >
                  <div className="flex-100 layout-row layout-align-space-between-start">
                    <div className="flex-none layout-row layout-align-space-around-center">
                      <TextHeading theme={theme} size={2} text="Insurance" />
                      <Tooltip theme={theme} icon="fa-info-circle" text="insurance" />
                    </div>

                    <div
                      className="flex-33 layout-row layout-align-space-around-center layout-wrap"
                    >
                      <div className="flex-100 layout-row layout-wrap layout-align-end-center">
                        <div className="flex-90 layout-row layout-align-start-center">
                          <p className="flex-none layout-align-start-center">
                            {`Yes, I want ${tenant.data.name} to insure my cargo`}
                          </p>
                        </div>
                        <div className="flex-10 layout-row layout-align-end-center">
                          <Checkbox
                            onChange={() => this.toggleInsurance(true)}
                            checked={this.props.insurance.bool}
                            theme={theme}
                          />
                        </div>
                      </div>
                      <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-90 layout-row layout-align-start-center">
                          <p className="flex-none" style={{ marginRight: '5px' }}>{`No, I do not want ${
                            tenant.data.name
                          } to insure my cargo`}
                          </p>
                        </div>
                        <div className="flex-10 layout-row layout-align-end-center">
                          <Checkbox
                            onChange={() => this.toggleInsurance(false)}
                            checked={
                              this.props.insurance.bool === null ? null : !this.props.insurance.bool
                            }
                            theme={theme}
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="flex-100 layout-row layout-align-start-center">
                    <p className="flex-100">
                      Cargo insurance provides protection against all risks of physical loss or
                      damage to freight from any external cause during shipping, whether by land,
                      sea or air.
                    </p>
                  </div>
                  {!this.state.insuranceView ? (
                    <div className="flex-100 layout-row layout-align-start-center">
                      <p className="flex-100">
                        <b>
                          Note that if you choose not to insure the goods it will only be covered by
                          carriers liability to the extent that it is covered under legal liability
                          standard to the transport industry.
                        </b>
                      </p>
                    </div>
                  ) : (
                    ''
                  )}
                  {insuranceBox}
                </div>
              </div>
            ) : (
              ''
            )}
            {scope.has_customs ? (
              <div className="flex-100 layout-row layout-align-center padd_top">
                <div
                  className={`flex-none ${
                    defaults.content_width
                  } layout-row layout-wrap section_padding`}
                >
                  <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
                    <div className="flex-none layout-row layout-align-space-around-center">
                      <TextHeading theme={theme} size={2} text="Customs Handling" />
                      <Tooltip theme={theme} icon="fa-info-circle" text="customs_clearance" />
                    </div>

                    <div
                      className="flex-33 layout-wrap layout-row layout-align-space-around-center"
                    >
                      <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-90 layout-row layout-align-start-center">
                          <p className="flex-none" style={{ marginRight: '5px' }}>
                            {`Yes, I want ${tenant.data.name} to handle my customs`}
                          </p>
                        </div>
                        <div className="flex-10 layout-row layout-align-end-center">
                          <Checkbox
                            onChange={() => this.toggleCustoms(true)}
                            checked={this.state.customsView}
                            theme={theme}
                          />
                        </div>
                      </div>
                      <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-90 layout-row layout-align-start-center">
                          <p className="flex-none" style={{ marginRight: '5px' }}>{`No, I do not want ${
                            tenant.data.name
                          } to handle my customs`}
                          </p>
                        </div>
                        <div className="flex-10 layout-row layout-align-end-center">
                          <Checkbox
                            onChange={() => this.toggleCustoms(false)}
                            checked={this.state.customsView === null
                              ? null : !this.state.customsView
                            }
                            theme={theme}
                          />
                        </div>
                      </div>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center">
                      <p className="flex-none">
                        A documented permission is needed (mandatory) to pass a national border when
                        exporting or importing. Power of Attorney may be required according to local
                        regulations.
                      </p>
                    </div>
                  </div>
                  {customsBox}
                  {noCustomsBox}
                </div>
              </div>
            ) : (
              ''
            )}
          </div>
        ) : (
          ''
        )}
      </div>
    )
  }
}
CargoDetails.propTypes = {
  theme: PropTypes.theme,
  tenant: PropTypes.objectOf(PropTypes.any),
  shipmentData: PropTypes.shipmentData.isRequired,
  handleChange: PropTypes.func.isRequired,
  handleInsurance: PropTypes.func.isRequired,
  // toggleCustomsCredit: PropTypes.func.isRequired,
  cargoNotes: PropTypes.string.isRequired,
  totalGoodsValue: PropTypes.number.isRequired,
  insurance: PropTypes.shape({
    val: PropTypes.any,
    bool: PropTypes.bool
  }).isRequired,
  customsData: PropTypes.shape({
    val: PropTypes.any
  }).isRequired,
  setCustomsFee: PropTypes.func.isRequired,
  shipmentDispatch: PropTypes.shape({
    deleteDocument: PropTypes.func,
    uploadDocument: PropTypes.func
  }).isRequired,
  currencies: PropTypes.arrayOf(PropTypes.shape({
    key: PropTypes.string,
    rate: PropTypes.number
  })).isRequired,
  hsCodes: PropTypes.arrayOf(PropTypes.string).isRequired,
  finishBookingAttempted: PropTypes.bool,
  hsTexts: PropTypes.objectOf(PropTypes.string),
  // handleHsTextChange: PropTypes.func,
  // customsCredit: PropTypes.bool,
  handleTotalGoodsCurrency: PropTypes.func.isRequired,
  eori: PropTypes.string,
  notes: PropTypes.string,
  incoterm: PropTypes.string
}

CargoDetails.defaultProps = {
  theme: null,
  tenant: null,
  finishBookingAttempted: false,
  hsTexts: {},
  // handleHsTextChange: null,
  // customsCredit: false,
  eori: '',
  notes: '',
  incoterm: ''
}

export default CargoDetails
