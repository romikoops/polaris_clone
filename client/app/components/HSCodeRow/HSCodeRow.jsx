import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import { NamedAsync } from '../NamedSelect/NamedAsync'
import { authHeader } from '../../helpers'
import styles from './HSCodeRow.scss'
import {
  CONTAINER_DESCRIPTIONS,
  // CONTAINER_TARE_WEIGHTS,
  getTenantApiUrl
} from '../../constants'
import { Tooltip } from '../Tooltip/Tooltip'
import TextHeading from '../TextHeading/TextHeading'
// import defs from '../../styles/default_classes.scss';
const containerDescriptions = CONTAINER_DESCRIPTIONS
class HSCodeRow extends Component {
  static reduceCargos (arr) {
    const results = []
    const uuids = {}
    arr.forEach((c) => {
      if (!uuids[c.cargo_group_id]) {
        uuids[c.cargo_group_id] = true
        results.push(c)
      }
    })

    return results
  }
  constructor (props) {
    super(props)
    this.state = {
      hsCodes: {},
      clipboard: {}
    }
    this.copyCodes = this.copyCodes.bind(this)
    this.pasteCodes = this.pasteCodes.bind(this)
    this.deleteCode = this.deleteCode.bind(this)
  }

  copyCodes (cgId) {
    this.setState({ clipboard: this.props.hsCodes[cgId], showPaste: true })
  }
  pasteCodes (cgId) {
    this.props.setCode(cgId, this.state.clipboard)
  }
  deleteCode (cargoId, code) {
    const codes = this.state.hsCodes[cargoId]
    const newCodes = codes.filter(x => x !== code)
    this.setState({
      hsCodes: {
        ...this.state.hsCodes,
        [cargoId]: newCodes
      }
    })
  }

  render () {
    const {
      containers, cargoItems, hsCodes, theme, tenant, hsTexts, t
    } = this.props
    const { showPaste } = this.state
    const containersAdded = []
    const cargoItemsAdded = []
    const getOptions = (input) => {
      const formData = new window.FormData()
      formData.append('query', input)
      const requestOptions = {
        method: 'POST',
        headers: { ...authHeader() },
        body: formData
      }

      return window
        .fetch(`${getTenantApiUrl()}/search/hscodes`, requestOptions)
        .then(response => response.json())
        .then(json => ({ options: json.data }))
      // }
      // return [];
    }

    const textInputBool = tenant && tenant.scope && tenant.scope.cargo_info_level && tenant.scope.cargo_info_level === 'text'
    const HSCell = ({ code, cargoId }) => (
      <div className={`flex-33 layout-row ${styles.hs_cell}`}>
        <p className="flex-none">{code.value}</p>
        <div className="flex-15 layout-row layout-align-center-center">
          <i className="fa fa-trash" onClick={() => this.props.deleteCode(cargoId, code)} />
        </div>
      </div>
    )
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const reducedContainers = containers ? HSCodeRow.reduceCargos(containers) : []
    const reducedCargoItems = cargoItems ? HSCodeRow.reduceCargos(cargoItems) : []
    if (reducedContainers) {
      reducedContainers.forEach((cont, i) => {
        const tmpCont = (
          <div
            className={`flex-100 layout-row layout-wrap ${styles.container_row}`}
            style={{ zIndex: `${200 - i}` }}
          >
            <div className="flex-15 layout-row layout-align-start-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:containerSize')}</p>
              <p className="flex-100">{containerDescriptions[cont.size_class]}</p>
            </div>
            <div className="flex-15 layout-row layout-align-start-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:netWeight')}</p>
              <p className="flex-100">{cont.payload_in_kg} kg</p>
            </div>
            <div className="flex-15 layout-row layout-align-start-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:grossWeight')}</p>
              <p className="flex-100">
                {parseInt(cont.payload_in_kg, 10) + parseInt(cont.tare_weight, 10)} kg
              </p>
            </div>
            <div className="flex-10 layout-row layout-align-start-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:dangerousGoods')}: </p>

              <p className="flex-100">{cont.dangerousGoods ? t('common:yes') : t('common:no')}</p>
            </div>
            <div className="flex-15 layout-row layout-align-start-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:copyPaste')}</p>

              <div className="flex-100 layout-row" style={{ margin: '1em 0' }}>
                <div
                  className="flex-50 layout-row layout-align-center-center"
                  onClick={() => this.copyCodes(cont.cargo_group_id)}
                >
                  <i className="fa fa-clone clip" style={textStyle} />
                </div>
                {showPaste ? (
                  <div
                    className="flex-50 layout-row layout-align-center-center"
                    onClick={() => this.pasteCodes(cont.cargo_group_id)}
                  >
                    <i className="fa fa-clipboard clip" style={textStyle} />
                  </div>
                ) : (
                  ''
                )}
              </div>
            </div>
            {
              textInputBool
                ? (
                  <div className="flex-100 layout-row layout-align-start-center">
                    <div className="input_box_full flex-80 layout-row layout-align-center-center">
                      <textarea name={`${cont.cargo_group_id}`} onChange={this.props.handleHsTextChange} value={hsTexts[cont.cargo_group_id]} id="" cols="30" rows="10" />
                    </div>
                  </div>
                )
                : (<div className="flex-100 layout-row layout-align-start-center">
                  <NamedAsync
                    classes="flex-50"
                    multi
                    name={cont.cargo_group_id}
                    value=""
                    autoload={false}
                    loadOptions={getOptions}
                    onChange={this.props.setCode}
                  />
                  <div className="flex-50 layout-row layout-wrap">
                    {hsCodes[cont.cargo_group_id]
                      ? hsCodes[cont.cargo_group_id].map(hs => (
                        <HSCell code={hs} cargoId={cont.cargo_group_id} />
                      ))
                      : ''}
                  </div>
                </div>)
            }
          </div>
        )
        containersAdded.push(tmpCont)
      })
    }
    if (reducedCargoItems) {
      reducedCargoItems.forEach((cont, i) => {
        const tmpCont = (
          <div
            // eslint-disable-next-line react/no-array-index-key
            key={i}
            className={`flex-100 layout-row layout-wrap ${styles.container_row}`}
            style={{ zIndex: `${200 - i}` }}
          >
            <div className="flex-10 layout-row layout-align-center-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:cargoGroup')}</p>
              <p className="flex-100">{i + 1}</p>
            </div>
            <div className="flex-15 layout-row layout-align-center-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:payload')}</p>
              <p className="flex-100">{cont.payload_in_kg} kg</p>
            </div>
            <div className="flex-15 layout-row layout-align-center-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:depth')}</p>
              <p className="flex-100">{cont.dimension_y} cm</p>
            </div>
            <div className="flex-15 layout-row layout-align-center-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:width')}</p>
              <p className="flex-100">{cont.dimension_x} cm</p>
            </div>
            <div className="flex-15 layout-row layout-align-center-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:height')}</p>
              <p className="flex-100">{cont.dimension_z} cm</p>
            </div>
            <div className="flex-15 layout-row layout-align-center-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:dangerousGoods')}: </p>
              <p className="flex-100">{cont.dangerousGoods ? t('common:yes') : t('common:no')}</p>
            </div>
            <div className="flex-15 layout-row layout-align-start-center layout-wrap">
              <p className={`flex-100 ${styles.cell_header}`}>{t('common:copyPaste')} </p>

              <div className="flex-100 layout-row" style={{ margin: '1em 0' }}>
                <div
                  className="flex-50 layout-row layout-align-center-center"
                  onClick={() => this.copyCodes(cont.cargo_group_id)}
                >
                  <i className="fa fa-clone clip" style={textStyle} />
                </div>

                <div
                  className="flex-50 layout-row layout-align-center-center"
                  onClick={() => this.pasteCodes(cont.cargo_group_id)}
                >
                  <i className="fa fa-clipboard clip" style={textStyle} />
                </div>
              </div>
            </div>
            {
              textInputBool
                ? (
                  <div className="flex-100 layout-row layout-align-start-center">
                    <div className="input_box_full flex-80 layout-row layout-align-center-center">
                      <textarea name={`${cont.cargo_group_id}`} onChange={this.props.handleHsTextChange} value={hsTexts[cont.cargo_group_id]} id="" cols="30" rows="10" />
                    </div>
                  </div>
                )
                : (<div className="flex-100 layout-row layout-align-start-center">
                  <NamedAsync
                    classes="flex-50"
                    multi
                    name={cont.cargo_group_id}
                    value=""
                    autoload={false}
                    loadOptions={getOptions}
                    onChange={this.props.setCode}
                  />
                  <div className="flex-50 layout-row layout-wrap">
                    {hsCodes[cont.cargo_group_id]
                      ? hsCodes[cont.cargo_group_id].map(hs => (
                        <HSCell code={hs} cargoId={cont.cargo_group_id} />
                      ))
                      : ''}
                  </div>
                </div>)
            }
          </div>
        )
        cargoItemsAdded.push(tmpCont)
      })
    }

    return (
      <div className="layout-row flex-100 layout-wrap layout-align-start-center">
        <div className="layout-row flex-none layout-wrap layout-align-start-center">
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div className="layout-row flex-100 layout-align-start-center">
              <div className="flex-none">
                <TextHeading theme={theme} size={2} text={t('common:hsCodes')} />
              </div>
              <Tooltip theme={theme} icon="fa-info-circle" text="hs_code" />
            </div>
            <div className="layout-row flex-100 layout-wrap">
              {containersAdded}
              {cargoItemsAdded}
            </div>
          </div>
        </div>
      </div>
    )
  }
}

HSCodeRow.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  tenant: PropTypes.objectOf(PropTypes.any),
  hsCodes: PropTypes.arrayOf(PropTypes.string),
  setCode: PropTypes.func.isRequired,
  deleteCode: PropTypes.func.isRequired,
  containers: PropTypes.arrayOf(PropTypes.shape({
    cargo_group_id: PropTypes.number
  })),
  cargoItems: PropTypes.arrayOf(PropTypes.shape({
    cargo_group_id: PropTypes.number
  })),
  hsTexts: PropTypes.objectOf(PropTypes.string),
  handleHsTextChange: PropTypes.func
}
HSCodeRow.defaultProps = {
  theme: null,
  tenant: {},
  hsCodes: [],
  containers: [],
  cargoItems: [],
  hsTexts: {},
  handleHsTextChange: null
}
export default withNamespaces('common')(HSCodeRow)
