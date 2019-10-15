import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './CargoDetails.scss'
import DocumentsForm from '../Documents/Form'
import DocumentsMultiForm from '../Documents/MultiForm'
import defaults from '../../styles/default_classes.scss'
import { converter } from '../../helpers'
import { currencyOptions, incotermInfo } from '../../constants'
import FormsyInput from '../FormsyInput/FormsyInput'
import TextHeading from '../TextHeading/TextHeading'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import FormsyTextarea from '../FormsyTextarea/FormsyTextarea'
import CustomsExportPaper from '../Addons/CustomsExportPaper'
import InsuranceSelection from '../InsuranceSelection/InsuranceSelection'
import CustomsClearance from '../CustomsClearance/CustomsClearance'
import { Modal } from '../Modal/Modal'

class CargoDetails extends Component {
  constructor (props) {
    super(props)
    this.state = {
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

  toggleCustomAddon (target) {
    const { toggleCustomAddon } = this.props
    toggleCustomAddon(target)
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
    if (tenant && tenant.scope.cargo_info_level === 'text') {
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
    if (event.target.value === '') return
    const { handleChange } = this.props
    handleChange(event)
  }

  toggleIncotermModal () {
    this.setState(prevState => ({
      showModal: !prevState.showModal
    }))
  }

  handleTotalGoodsCurrency (selection) {
    const { handleTotalGoodsCurrency } = this.props
    this.setState({ totalGoodsCurrency: selection })
    handleTotalGoodsCurrency(selection.value)
  }

  render () {
    const { totalGoodsCurrency, insuranceView } = this.state
    const {
      customsData,
      eori,
      finishBookingAttempted,
      shipmentData,
      t,
      tenant,
      theme,
      totalGoodsValue,
      setAddons,
      insurance,
      handleInsurance
    } = this.props

    const { scope } = tenant
    const mandatoryFormFields = scope.mandatory_form_fields || {}
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

    return (
      <div name="cargoDetailsBox" className="flex-100 layout-row layout-wrap padd_top">
        {scope.customs_export_paper && addons.customs_export_paper
          ? (
            <div className="flex-100 layout-row layout-align-center padd_top">
              <div
                className={`flex-none ${
                  defaults.content_width
                } layout-row layout-wrap section_padding`}
              >
                <CustomsExportPaper
                  addon={addons.customs_export_paper}
                  tenant={tenant}
                  isSet={setAddons.customs_export_paper}
                  documents={documents}
                  fileFn={this.fileFn}
                  deleteDoc={this.deleteDoc}
                  toggleCustomAddon={this.toggleCustomAddon}
                />
              </div>
            </div>
          )
          : ''}
        {this.state.showModal ? modal : ''}
        <div className="flex-100 layout-row layout-align-center">
          <div className={`flex-none ${defaults.content_width} layout-row layout-wrap`}>
            <div className="flex-100 layout-row layout-sm-wrap">

              <div className="flex-50">
                <div className="flex-100">
                  <div className="flex-100 layout-align-start-center layout-row">
                    <div className="flex-none">
                      <TextHeading
                        theme={theme}
                        size={2}
                        text={t('cargo:cargoDetails')}
                      />
                    </div>
                  </div>
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
                  className="flex-100 layout-row layout-wrap
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
                          validations={{ nonNegative: (values, value) => !mandatoryFormFields.total_goods_value || value > 0 }}
                          validationErrors={{
                            nonNegative: t('common:greaterZero'),
                            isDefaultRequiredValue: t('common:greaterZero')
                          }}
                          required={mandatoryFormFields.total_goods_value}
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
                        required={mandatoryFormFields.description_of_goods}
                      />
                    </div>
                  </div>
                  <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                    <div className="flex-100">
                      <div className={`flex-none ${styles.f_header}`}>
                        {' '}
                        <h4 className="no_m flex-30">
                        Incoterms
                          {' '}
                          <span>(Optional)</span>
                        </h4>
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
              </div>
              <div
                className="flex-50 padding_left offset-gt-sm-5
                  layout-row layout-wrap layout-align-start-start"
              >
                <div className="flex-100 layout-align-start-center layout-row">
                  <div className="flex-none">
                    <TextHeading
                      theme={theme}
                      size={2}
                      text={t('cargo:shipmentDocuments')}
                    />
                    <br />
                    {t('common:ifAvailable')}
                  </div>
                </div>
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
                {dangerousGoods && (
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
            {scope.has_customs && (
              <CustomsClearance
                tenant={tenant}
                theme={theme}
                t={t}
                totalGoodsValue={totalGoodsValue}
                deleteDoc={this.deleteDoc}
                dispatchFn={this.fileFn}
                documents={documents}
                shipment={shipment}
                eori={eori}
                customs={customs}
                customsData={customsData}
                handleChange={this.handleChange}
              />
            )}
            {scope.has_insurance && (
              <InsuranceSelection
                theme={theme}
                tenant={tenant}
                insuranceBool={insurance.bool}
                insuranceView={insuranceView}
                handleInsurance={handleInsurance}
                t={t}
              />
            )}

          </div>
        ) : (
          ''
        )}
      </div>
    )
  }
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
