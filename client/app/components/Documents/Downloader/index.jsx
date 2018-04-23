import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Promise } from 'es6-promise-promise'
import { v4 } from 'node-uuid'
import PropTypes from '../../../prop-types'
import { documentActions } from '../../../actions'
import { RoundButton } from '../../RoundButton/RoundButton'
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
        documentDispatch.downloadPricings()
        break
      case 'hubs':
        documentDispatch.downloadHubs()
        break
      case 'trucking':
        documentDispatch.downloadTrucking(options)
        break
      case 'local_charges':
        documentDispatch.downloadLocalCharges()
        break
      case 'schedules':
        documentDispatch.downloadSchedules(options)
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
    // this.setState({ requested: false })
  }
  render () {
    const { theme, loading, tooltip } = this.props
    const { requested } = this.state
    const tooltipId = v4()
    // const errorStyle = this.state.error ? styles.error : ''
    const start = (
      <RoundButton
        text="Request"
        theme={theme}
        size="small"
        handleNext={() => this.requestDocument()}
        active
      />
    )
    const loadingBox = (
      <div className="flex-100 layout-column layout-align-space-around-center">
        <p className="flex-none">Your document is being generated.</p>
        <p className="flex-none">Please wait....</p>
      </div>
    )
    const ready = (
      <RoundButton
        text="Download"
        theme={theme}
        size="small"
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
        className={`flex-none layout-row ${styles.upload_btn_wrapper} `}
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
  documentDispatch: PropTypes.func.isRequired,
  downloadUrls: PropTypes.objectOf(PropTypes.any),
  tooltip: PropTypes.string,
  // viewer: PropTypes.bool,
  target: PropTypes.string,
  loading: PropTypes.bool,
  options: PropTypes.objectOf(PropTypes.any)
}

DocumentsDownloader.defaultProps = {
  // viewer: false,
  downloadUrls: {},
  theme: null,
  tooltip: '',
  target: '',
  loading: false,
  options: {}
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

export default connect(mapStateToProps, mapDispatchToProps)(DocumentsDownloader)
