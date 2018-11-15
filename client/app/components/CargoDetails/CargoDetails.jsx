import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../prop-types'
import styles from './CargoDetails.scss'
import Checkbox from '../Checkbox/Checkbox'
import DocumentsForm from '../Documents/Form'
import DocumentsMultiForm from '../Documents/MultiForm'
import defaults from '../../styles/default_classes.scss'
import { converter } from '../../helpers'
import { currencyOptions, tooltips, incotermInfo } from '../../constants'
import FormsyInput from '../FormsyInput/FormsyInput'
import TextHeading from '../TextHeading/TextHeading'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import FormsyTextarea from '../FormsyTextarea/FormsyTextarea'
import CustomsExportPaper from '../Addons/CustomsExportPaper'
import { Modal } from '../Modal/Modal'

class CargoDetails extends Component {
  static displayCustomsFee (customsData, target, customs, t) {
    if (target === 'total') {
      let newTotal = 0
      if (customsData.import.bool && !customs.import.unknown) {
        newTotal += parseFloat(customs.import.total.value)
      }
      if (customsData.export.bool && !customs.export.unknown) {
        newTotal += parseFloat(customs.export.total.value)
      }
      if (newTotal === 0 && customs.import.unknown && customs.export.unknown) {
        return t('cargo:priceLocalRegulations')
      }

      return `${newTotal.toFixed(2)} ${customs.total.total.currency}`
    }
    if (customsData[target].bool) {
      if (customs) {
        const fee = customs[target]

        if (fee && !fee.unknown && fee.total.value) {
          return `${parseFloat(fee.total.value).toFixed(2)} ${fee.total.currency}`
        }

        return t('cargo:priceLocalRegulations')
      }
    }
    if (customsData[target].unknown) {
      return t('cargo:priceLocalRegulations')
    }

    return '0 EUR'
  }
  constructor (props) {
    super(props)
    this.state = {
      customsView: null,
      insuranceView: null,
      totalGoodsCurrency: {
        label: 'EUR',
        value: 'EUR'
      },
      showModal: false
    }

    this.calcCustomsFee = this.calcCustomsFee.bind(this)
    this.deleteDoc = this.deleteDoc.bind(this)
    this.fileFn = this.fileFn.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.handleTotalGoodsCurrency = this.handleTotalGoodsCurrency.bind(this)
    this.toggleCustomAddon = this.toggleCustomAddon.bind(this)
  }
  toggleInsurance (bool) {
    this.setState({ insuranceView: bool })
    this.props.handleInsurance(bool)
  }
  toggleCustoms (bool) {
    this.setState({ customsView: bool })
  }
  toggleCustomAddon (target) {
    this.props.toggleCustomAddon(target)
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

    setCustomsFee(target, resp)
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
  toggleIncotermModal () {
    this.setState(prevState => ({
      showModal: !prevState.showModal
    }))
  }
  handleTotalGoodsCurrency (selection) {
    this.setState({ totalGoodsCurrency: selection })
    this.props.handleTotalGoodsCurrency(selection.value)
  }
  insuranceReadMore () {
    const { tenant } = this.props
    const url = `http://${tenant.data.subdomain}.itsmycargo.com/insurance`
    window.open(url, '_blank')
  }
  render () {
    const { totalGoodsCurrency } = this.state
    const {
      customsData,
      eori,
      finishBookingAttempted,
      shipmentData,
      t,
      tenant,
      theme,
      totalGoodsValue
    } = this.props

    const { scope } = tenant.data
    const {
      addons,
      customs,
      dangerousGoods,
      documents,
      shipment
    } = shipmentData

    const incotermBox = (
      <div className="flex-100 layout-wrap layout-row">
        <p>{incotermInfo.description}</p>
        <div>
          {Object.entries(incotermInfo.incoterms).map(array => (
            <div className={`flex-70 ${styles.incoterm_row}`}>
              <h4 style={{ color: theme.colors.primary }}>{array[1].title}</h4>
              <p>{array[1].info}</p>
              <p className={`${styles.incoterm_desc}`}>{array[1].description}</p>
            </div>
          ))}
        </div>
      </div>
    )

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
              {t('cargo:costEffective')}
            </strong>
          </p>
          <p className="flex-90">
            {t('cargo:insuranceContact', { tenantName: tenant.data.name })}
          </p>
        </div>
      </div>
    )
    const fadedPreCarriageText = shipment.has_pre_carriage ? '' : styles.faded_text
    const fadedOnCarriageText = shipment.has_on_carriage ? '' : styles.faded_text
    const textComp = (
      <b style={{ fontWeight: 'normal', fontSize: '.83em' }}>
        ({t('cargo:ifApplicable')})
      </b>
    )

    const modal = (
      <Modal
        showExit
        flexOptions="flex-80"
        component={incotermBox}
        verticalPadding="65px"
        maxWidth="70%"
        horizontalPadding="55px"
        parentToggle={() => this.toggleIncotermModal()}
      />
    )

    const handleText = `${t('cargo:handleHead')} ${tenant.data.name} ${t('cargo:handleTail')}:`
    const customsBox = (
      <div
        className={`flex-100 layout-row layout-wrap ${styles.customs_box}  ${styles.box_content} ${
          this.state.customsView ? styles.show : styles.hidden
        }`}
      >
        <div className="flex-60 layout-row layout-wrap">
          <p className="flex-90 margin_5">
            <strong>
              {' '}
              {t('cargo:conditionFirst')}
            </strong>
          </p>
          <p className="flex-90 margin_5">
            {t('cargo:conditionSecond')}
          </p>
          <div className="flex-100 layout-row layout-align-start-start layout-wrap">
            <div
              className="flex-100 layout-row layout-align-start-center"
              style={{ height: '36px' }}
            >
              <p className="flex-none"> {handleText}</p>
            </div>
            <div
              className="flex-100 layout-row layout-align-start-center layout-wrap"
              style={{ height: '36px' }}
            >
              <div
                className="flex-45 layout-row layout-align-space-around-center"
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
                className="flex-45 layout-row layout-align-space-around-center"
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
            <div className="flex-100 no_max layout-row layout-align-start-center">
              <div className="flex-33 layout-row layout-wrap">
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
                    placeholder={t('cargo:typeEORI')}
                  />
                </div>
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
              {CargoDetails.displayCustomsFee(customsData, 'import', customs, t)}
            </h6>
          </div>
          <div className={`${styles.customs_prices} flex-100 layout-row  layout-align-end-center`}>
            <p className="flex-none">Export</p>
            <h6 className="flex-none center">
              {' '}
              {CargoDetails.displayCustomsFee(customsData, 'export', customs, t)}
            </h6>
          </div>

          <div className={`${styles.customs_total} flex-100 layout-row  layout-align-end-center`}>
            <p className="flex-none">Total</p>
            <h6 className="flex-none center">
              {' '}
              {CargoDetails.displayCustomsFee(customsData, 'total', customs, t)}
            </h6>
          </div>
        </div>
      </div>
    )

    const noCustomsText = `${t('cargo:noCustomsHead')} ${tenant.data.name} ${t('cargo:noCustomsTail')}`

    const noCustomsBox = (
      <div
        className={`flex-100 layout-row layout-align-start-center layout-wrap ${
          styles.no_customs_box
        } ${!this.state.customsView ? styles.show : ''}`}
      >
        <div className="flex-60 layout-row layout-align-start-center layout-wrap">
          <p className="flex-100 margin_5">
            <b>
              {noCustomsText}
            </b>
          </p>
          <p className="flex-100 margin_5">
            <b>
              {t('cargo:euRules')}
            </b>
          </p>
        </div>
        <div className="flex-33 no_max layout-row layout-align-end-center">
          {this.props.totalGoodsValue.value > 20000 ? (
            <div className="flex-90 layout-row layout-wrap">
              <div className="flex-100">
                <TextHeading
                  theme={theme}
                  size={3}
                  text={t('cargo:customsValue')}
                />
              </div>
              <div className="flex-100 layout-row layout-wrap" name="customs_value_declaration">
                <div className="flex-100 layout-row">
                  <DocumentsForm
                    theme={theme}
                    type="customs_value_declaration"
                    text={t('cargo:customsValueShort')}
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

    const quoteInsurance = `${t('cargo:quoteInsuranceHead')} ${tenant.data.name} ${t('cargo:quoteInsuranceTail')}`
    const quoteInsuranceNegative = `${t('cargo:quoteInsuranceNoHead')} ${tenant.data.name} ${t('cargo:quoteInsuranceNoTail')}`
    const clearance = `${t('cargo:clearanceHead')} ${tenant.data.name} ${t('cargo:clearanceTail')}`
    const clearanceNegative = `${t('cargo:clearanceNoHead')} ${tenant.data.name} ${t('cargo:clearanceNoTail')}`

    return (
      <div name="cargoDetailsBox" className="flex-100 layout-row layout-wrap padd_top">
        {scope.customs_export_paper && addons.customs_export_paper
          ? <div className="flex-100 layout-row layout-align-center padd_top">
            <div
              className={`flex-none ${
                defaults.content_width
              } layout-row layout-wrap section_padding`}
            >
              <CustomsExportPaper
                addon={addons.customs_export_paper}
                tenant={tenant}
                documents={documents}
                fileFn={this.fileFn}
                deleteDoc={this.deleteDoc}
                toggleCustomAddon={this.toggleCustomAddon}
              />
            </div>
          </div>
          : ''}
        {this.state.showModal ? modal : ''}
        <div className="flex-100 layout-row layout-align-center">
          <div className={`flex-none ${defaults.content_width} layout-row layout-wrap`}>
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div className="flex-45 layout-align-start-center layout-row">
                <div className="flex-none">
                  <TextHeading
                    theme={theme}
                    size={2}
                    text={t('cargo:cargoDetails')}
                  />
                </div>
              </div>
              <div className="flex-45 layout-align-start-center layout-row">
                <div className="flex-none">
                  <TextHeading
                    theme={theme}
                    size={2}
                    text={t('cargo:shipmentDocuments')}
                  />
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
                  <TextHeading
                    theme={theme}
                    size={3}
                    text={t('cargo:totalValue')}
                  />
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
                        className={`flex-100 ccb_total_goods_value ${styles.cargo_input} `}
                        wrapperClassName={`flex-100 ${styles.wrapper_cargo_input}`}
                        errorMessageStyles={{
                          fontSize: '13px',
                          bottom: '-17px'
                        }}
                        value={totalGoodsValue.value}
                        type="number"
                        name="totalGoodsValue"
                        onBlur={this.handleChange}
                        submitAttempted={finishBookingAttempted}
                        validations={{ nonNegative: (values, value) => value > 0 }}
                        validationErrors={{
                          nonNegative: t('common:greaterZero'),
                          isDefaultRequiredValue: t('common:greaterZero')
                        }}
                        required
                      />
                    </div>
                    <div className="flex-33 layout-row">
                      <NamedSelect
                        className="flex-100 ccb_currency"
                        options={currencyOptions}
                        onChange={this.handleTotalGoodsCurrency}
                        value={totalGoodsCurrency}
                        clearable={false}
                      />
                    </div>
                  </div>
                </div>
                <div className="flex-100 layout-row layout-wrap" id="cargo_notes">
                  <div className="flex-100">
                    <div className={`flex-none ${styles.f_header}`}>
                      {' '}
                      <TextHeading
                        theme={theme}
                        size={3}
                        text={t('cargo:descriptionGoods')}
                      />
                    </div>
                  </div>
                  <div className="flex-100">
                    <FormsyTextarea
                      className={`flex-100 ccb_description_goods ${styles.cargo_text_area} `}
                      wrapperClassName={`flex-100 ${styles.wrapper_cargo_input}`}
                      errorMessageStyles={{
                        fontSize: '13px',
                        bottom: '-17px'
                      }}
                      type="textarea"
                      name="cargoNotes"
                      value={this.props.cargoNotes}
                      onBlur={this.handleChange}
                      submitAttempted={finishBookingAttempted}
                      validationErrors={{
                        isDefaultRequiredValue: t('common:nonEmpty')
                      }}
                      required
                    />
                  </div>
                </div>
                <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                  <div className="flex-100">
                    <div className={`flex-none ${styles.f_header}`}>
                      {' '}
                      <h4 className="no_m flex-30">Incoterms <span>(Optional)</span></h4>
                      <p
                        className={`pointy flex-none ${styles.incoterm_info}`}
                        onClick={() => this.toggleIncotermModal()}
                      >
                        More info
                      </p>

                    </div>
                  </div>
                  <div className="flex-100 layout-row layout-align-start-start input_box_full">
                    <FormsyTextarea
                      className={`flex-100 ${styles.cargo_text_area} `}
                      wrapperClassName={`flex-100 ${styles.wrapper_cargo_input}`}
                      errorMessageStyles={{
                        fontSize: '13px',
                        bottom: '-17px'
                      }}
                      type="textarea"
                      name="incotermText"
                      value={this.props.incotermText}
                      onBlur={this.handleChange}
                      submitAttempted={finishBookingAttempted}
                    />
                  </div>
                </div>
              </div>
              <div
                className="flex-100 flex-gt-sm-45 offset-gt-sm-5
                  layout-row layout-wrap layout-align-start-start"
              >
                <div className="flex-100 layout-row layout-wrap" name="packing_sheet">
                  <div className="flex-100 layout-row margin_5">
                    <DocumentsMultiForm
                      theme={theme}
                      type="packing_sheet"
                      dispatchFn={this.fileFn}
                      text={t('common:packingSheet')}
                      documents={documents.packing_sheet}
                      isRequired
                      deleteFn={this.deleteDoc}
                    />
                  </div>
                </div>

                <div className="flex-100 layout-row layout-wrap" name="commercial_invoice">
                  <div className="flex-100 layout-row margin_5">
                    <DocumentsMultiForm
                      theme={theme}
                      type="commercial_invoice"
                      dispatchFn={this.fileFn}
                      text={t('common:commercialInvoice')}
                      documents={documents.commercial_invoice}
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
                        text={t('common:dangerousGoods')}
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
                        <TextHeading
                          theme={theme}
                          size={3}
                          text={t('cargo:notesOptional')}
                        />
                      </div>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-start input_box_full">
                      <FormsyTextarea
                        className={`flex-100 ${styles.cargo_text_area} `}
                        wrapperClassName={`flex-100 ${styles.wrapper_cargo_input}`}
                        errorMessageStyles={{
                          fontSize: '13px',
                          bottom: '-17px'
                        }}
                        type="textarea"
                        name="notes"
                        value={this.props.notes}
                        onBlur={this.handleChange}
                        submitAttempted={finishBookingAttempted}
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
                        text={t('common:miscellaneous')}
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
        {scope.has_customs || scope.has_insurance || scope.customs_export_paper ? (
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
                      <TextHeading
                        theme={theme}
                        size={2}
                        text={t('common:insurance')}
                      />
                    </div>

                    <div
                      className="flex-33 layout-row layout-align-space-around-center layout-wrap"
                    >
                      <div className="flex-100 layout-row layout-wrap layout-align-end-center">
                        <div className="flex-90 layout-row layout-align-start-center">
                          <label htmlFor="yes_insurance" className="pointy">
                            {quoteInsurance}
                          </label>
                        </div>
                        <div className="flex-10 layout-row layout-align-end-center">
                          <Checkbox
                            id="yes_insurance"
                            className="ccb_yes_insurance"
                            onChange={() => this.toggleInsurance(true)}
                            checked={this.props.insurance.bool}
                            theme={theme}
                          />
                        </div>
                      </div>
                      <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-90 layout-row layout-align-start-center">
                          <label htmlFor="no_insurance" className="pointy">
                            {quoteInsuranceNegative}
                          </label>
                        </div>
                        <div className="flex-10 layout-row layout-align-end-center">
                          <Checkbox
                            id="no_insurance"
                            className="ccb_no_insurance"
                            onChange={() => this.toggleInsurance(false)}
                            checked={this.props.insurance.bool === null ? null : !this.props.insurance.bool}
                            theme={theme}
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="flex-100 layout-row layout-align-start-center">
                    <p className="flex-60 margin_5">
                      <b>
                        {t('cargo:cargoInsurance')}
                      </b>
                    </p>
                  </div>
                  {!this.state.insuranceView ? (
                    <div className="flex-100 layout-row layout-align-start-center">
                      <p className="flex-60 margin_5">
                        <b>
                          {t('cargo:effectiveInsurance')}
                        </b>
                      </p>
                    </div>
                  ) : (
                    ''
                  )}
                  {insuranceBox}
                  <div className="flex-100 layout-row layout-align-start-center">
                    <div
                      className="flex-none layout-row layout-align-center-center"
                      onClick={() => this.insuranceReadMore()}
                    >
                      <p className="flex-none pointy">{t('common:readMore')}</p>
                      <i className="flex-none offset-5 fa fa-external-link" />
                    </div>
                  </div>
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
                      <TextHeading
                        theme={theme}
                        size={2}
                        text={t('cargo:customsHandling')}
                      />
                    </div>

                    <div
                      className="flex-33 layout-wrap layout-row layout-align-space-around-center"
                    >
                      <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-90 layout-row layout-align-start-center">
                          <label htmlFor="yes_clearance" className="pointy">
                            {clearance}
                          </label>
                        </div>
                        <div className="flex-10 layout-row layout-align-end-center">
                          <Checkbox
                            id="yes_clearance"
                            className="ccb_yes_clearance"
                            onChange={() => this.toggleCustoms(true)}
                            checked={this.state.customsView}
                            theme={theme}
                          />
                        </div>
                      </div>
                      <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-90 layout-row layout-align-start-center">
                          <label htmlFor="no_clearance" className="pointy">
                            {clearanceNegative}
                          </label>
                        </div>
                        <div className="flex-10 layout-row layout-align-end-center">
                          <Checkbox
                            id="no_clearance"
                            onChange={() => this.toggleCustoms(false)}
                            className="ccb_no_clearance"
                            checked={this.state.customsView === null ? null : !this.state.customsView}
                            theme={theme}
                          />
                        </div>
                      </div>
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
  t: PropTypes.func.isRequired,
  tenant: PropTypes.objectOf(PropTypes.any),
  shipmentData: PropTypes.shipmentData.isRequired,
  handleChange: PropTypes.func.isRequired,
  handleInsurance: PropTypes.func.isRequired,
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
  toggleCustomAddon: PropTypes.func,
  handleTotalGoodsCurrency: PropTypes.func.isRequired,
  eori: PropTypes.string,
  notes: PropTypes.string,
  incotermText: PropTypes.string
}

CargoDetails.defaultProps = {
  theme: null,
  tenant: null,
  finishBookingAttempted: false,
  hsTexts: {},
  toggleCustomAddon: null,
  eori: '',
  notes: '',
  incotermText: ''
}

export default withNamespaces(['common', 'cargo'])(CargoDetails)
