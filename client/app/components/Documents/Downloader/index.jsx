import React from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import { documentActions } from '../../../actions'
import { RoundButton } from '../../RoundButton/RoundButton'
import SquareButton from '../../SquareButton'
import { LoadingSpinner } from '../../LoadingSpinner/LoadingSpinner'
import styles from './index.scss'
import NamedSelect from '../../NamedSelect/NamedSelect'

class DocumentsDownloader extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      requested: null
    }
  }

  requestDocument (arg) {
    const { target, documentDispatch, options } = this.props

    switch (target) {
      case 'pricing_cargo_item':
        documentDispatch.downloadPricings(options)
        break
      case 'pricing_container':
        documentDispatch.downloadPricings(options)
        break
      case 'hubs':
        documentDispatch.downloadHubs()
        break
      case 'trucking': {
        if (arg) {
          options.target = arg.value
        }
        documentDispatch.downloadTrucking(options)
        break
      }
      case 'local_charges':
        documentDispatch.downloadLocalCharges(options)
        break
      case 'schedules':
        documentDispatch.downloadSchedules(options)
        break
      case 'clients':
        documentDispatch.downloadClients()
        break
      case 'gdpr':
        documentDispatch.downloadGdpr(options)
        break
      case 'shipment_recap':
        documentDispatch.downloadShipment(options)
        break
      case 'charge_categories':
        documentDispatch.downloadChargeCategories()
        break
      case 'quotations':
        documentDispatch.downloadQuotations(options)
        break
      case 'quote':
        documentDispatch.downloadQuote(options)
        break
      default:
        break
    }
    this.setState({ requested: true })
  }

  downloadFile () {
    const { downloadUrls, target } = this.props
    if (downloadUrls[target]) {
      window.location = downloadUrls[target]
    }
    this.setState({ requested: false })
  }

  render () {
    const {
      theme, loading, tooltip, square, size, t, disabled, targetOptions
    } = this.props
    const { requested, selected } = this.state
    const tooltipId = v4()
    const start = square ? (
      <SquareButton
        classNames="request"
        text={t('doc:download')}
        theme={theme}
        size={size}
        disabled={disabled}
        handleNext={() => this.requestDocument()}
        active={!disabled}
        border
      />
    ) : (
      <RoundButton
        classNames="request"
        text={t('doc:download')}
        theme={theme}
        size={size}
        disabled={disabled}
        handleNext={() => this.requestDocument()}
        active={!disabled}
      />
    )
    const selectBox = (
      <div className="flex-100 layout-row layout-align-center-center">
        <NamedSelect
          theme={theme}
          options={targetOptions}
          value={selected}
          className="flex-100"
          clearable={false}
          onChange={e => this.requestDocument(e)}
        />
      </div>
    )
    const loadingBox = (
      <LoadingSpinner size="small" />
    )
    const ready = square ? (
      <SquareButton
        classNames="request"
        text={t('doc:download')}
        theme={theme}
        size={size}
        disabled={disabled}
        handleNext={() => this.downloadFile()}
        active={!disabled}
        border
      />
    ) : (
      <RoundButton
        classNames="ready"
        text={t('doc:download')}
        theme={theme}
        disabled={disabled}
        size={size}
        handleNext={() => this.downloadFile()}
        active={!disabled}
      />
    )
    let button
    if (!loading && !requested) {
      button = targetOptions.length > 0 ? selectBox : start
    } else if (loading && requested) {
      button = loadingBox
    } else if (!loading && requested) {
      button = ready
      this.downloadFile()
    }

    return (
      <div
        className={`flex-none layout-row layout-align-center-center document_downloader ${styles.upload_btn_wrapper} `}
        data-tip={tooltip}
        data-for={tooltipId}
      >
        {button}
      </div>
    )
  }
}

DocumentsDownloader.defaultProps = {
  square: false,
  downloadUrls: {},
  documentDispatch: null,
  theme: null,
  tooltip: '',
  target: '',
  loading: false,
  options: {},
  size: 'small',
  disabled: false,
  targetOptions: []
}

function mapStateToProps (state) {
  const { authentication, document, app } = state
  const { tenant } = app
  const { user, loggedIn } = authentication
  const { downloadUrls, viewer, loading } = document

  return {
    user,
    tenant,
    loggedIn,
    loading,
    downloadUrls,
    viewer
  }
}
function mapDispatchToProps (dispatch) {
  return {
    documentDispatch: bindActionCreators(documentActions, dispatch)
  }
}

export default withNamespaces(['common', 'doc'])(connect(mapStateToProps, mapDispatchToProps)(DocumentsDownloader))
