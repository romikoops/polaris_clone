import React from 'react'
import { translate } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Promise } from 'es6-promise-promise'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import { documentActions } from '../../../actions'
import { RoundButton } from '../../RoundButton/RoundButton'
import SquareButton from '../../SquareButton'
import styles from './index.scss'

class DocumentsDownloader extends React.Component {
  static handleResponse (response) {
    if (!response.ok) {
      return Promise.reject(response.statusText)
    }

    return response.json()
  }
  constructor (props) {
    super(props)
    this.state = {
      requested: null
    }
  }

  requestDocument () {
    const { target, documentDispatch, options } = this.props
    switch (target) {
      case 'pricing':
        documentDispatch.downloadPricings(options)
        break
      case 'hubs':
        documentDispatch.downloadHubs()
        break
      case 'trucking':
        documentDispatch.downloadTrucking(options)
        break
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
      case 'quotations':
        documentDispatch.downloadQuotations(options)
        break

      default:
        break
    }
    this.setState({ requested: true })
  }

  downloadFile () {
    const { downloadUrls, target } = this.props

    if (downloadUrls[target]) {
      window.open(downloadUrls[target], '_blank')
    }
  }
  render () {
    const {
      theme, loading, tooltip, square, size, t
    } = this.props
    const { requested } = this.state
    const tooltipId = v4()
    const start = square ? (
      <SquareButton
        text={t('common:request')}
        theme={theme}
        size={size}
        handleNext={() => this.requestDocument()}
        active
        border
      />
    ) : (
      <RoundButton
        text={t('common:request')}
        theme={theme}
        size={size}
        handleNext={() => this.requestDocument()}
        active
      />
    )
    const loadingBox = (
      <div className="flex-100 layout-column layout-align-space-around-center">
        <p className="flex-none">{t('doc:generated')}</p>
        <p className="flex-none">{t('doc:pleaseWait')}</p>
      </div>
    )
    const ready = square ? (
      <SquareButton
        text={t('doc:download')}
        theme={theme}
        size={size}
        handleNext={() => this.downloadFile()}
        active
        border
      />
    ) : (
      <RoundButton
        text={t('doc:download')}
        theme={theme}
        size={size}
        handleNext={() => this.downloadFile()}
        active
      />
    )
    let button
    if (!loading && !requested) {
      button = start
    } else if (loading && requested) {
      button = loadingBox
    } else if (!loading && requested) {
      button = ready
    }

    return (
      <div
        className={`flex-none layout-row layout-align-center-center ${styles.upload_btn_wrapper} `}
        data-tip={tooltip}
        data-for={tooltipId}
      >
        {button}
      </div>
    )
  }
}

DocumentsDownloader.propTypes = {
  theme: PropTypes.theme,
  documentDispatch: PropTypes.func,
  t: PropTypes.func.isRequired,
  downloadUrls: PropTypes.objectOf(PropTypes.any),
  tooltip: PropTypes.string,
  square: PropTypes.bool,
  target: PropTypes.string,
  loading: PropTypes.bool,
  options: PropTypes.objectOf(PropTypes.any),
  size: PropTypes.string
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
  size: 'small'
}

function mapStateToProps (state) {
  const { authentication, tenant, document } = state
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

export default translate(['common', 'doc'])(connect(mapStateToProps, mapDispatchToProps)(DocumentsDownloader))
