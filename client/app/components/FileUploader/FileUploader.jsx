import React from 'react'
import { withNamespaces } from 'react-i18next'
import fetch from 'isomorphic-fetch'
import { Promise } from 'es6-promise-promise'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import getApiHost from '../../constants/api.constants'
import { authHeader } from '../../helpers'
import { RoundButton } from '../RoundButton/RoundButton'
import SquareButton from '../SquareButton'
import styles from './FileUploader.scss'

class FileUploader extends React.Component {
  static handleResponse (response) {
    if (!response.ok) {
      return Promise.reject(response.statusText)
    }

    return response.json()
  }
  constructor (props) {
    super(props)
    this.state = {
      file: null,
      error: false
    }
    this.onFormSubmit = this.onFormSubmit.bind(this)
    this.onChange = this.onChange.bind(this)
    this.fileUpload = this.fileUpload.bind(this)
  }
  onFormSubmit (e) {
    e.preventDefault()
    if (this.state.file) {
      this.fileUpload(this.state.file)
    }
  }
  onChange (e) {
    this.fileUpload(e.target.files[0])
  }
  fileUpload (baseFile) {
    const file = baseFile
    const {
      url, type, dispatchFn, uploadFn
    } = this.props
    if (!file) {
      return ''
    }
    if (dispatchFn) {
      if (type) {
        file.doc_type = type
      }
      dispatchFn(file)
      if (this.uploaderInput.files.length) {
        this.uploaderInput.value = ''
      }

      return null
    }
    if (uploadFn) {
      return uploadFn(file, type, url)
    }
    const formData = new window.FormData()
    formData.append('file', file)
    formData.append('type', type)
    const requestOptions = {
      method: 'POST',
      headers: { ...authHeader() },
      body: formData
    }
    const uploadUrl = getApiHost() + url
    fetch(uploadUrl, requestOptions).then(FileUploader.handleResponse)
    if (this.uploaderInput.files.length) {
      this.uploaderInput.value = ''
    }

    return null
  }
  showFileTypeError () {
    this.setState({ error: true })
    this.alertTimeout = setTimeout(() => this.setState({ error: false }), 5000)
  }
  clickUploaderInput (e) {
    e.preventDefault()
    this.uploaderInput.click()
  }
  render () {
    const {
      theme, type, tooltip, square, size, t, formClasses
    } = this.props
    const tooltipId = v4()
    const errorStyle = this.state.error ? styles.error : ''

    return (
      <div
        className={`flex-none layout-row ${styles.upload_btn_wrapper} `}
        data-tip={tooltip}
        data-for={tooltipId}
      >
        <form className={formClasses || ''}>
          {square ? (
            <SquareButton
              text={t('common:upload')}
              theme={theme}
              size={size}
              handleNext={e => this.clickUploaderInput(e)}
              active
              border
            />
          ) : (
            <RoundButton
              text={t('common:upload')}
              theme={theme}
              size={size}
              handleNext={e => this.clickUploaderInput(e)}
              active
            />
          )}

          <ReactTooltip id={tooltipId} className={styles.tooltip} effect="solid" />
          <input
            type="file"
            onChange={this.onChange}
            name={type}
            ref={(input) => {
              this.uploaderInput = input
            }}
          />
        </form>
      </div>
    )
  }
}

FileUploader.propTypes = {
  url: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  square: PropTypes.bool,
  type: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  dispatchFn: PropTypes.func,
  uploadFn: PropTypes.func,
  tooltip: PropTypes.string,
  formClasses: PropTypes.string,
  size: PropTypes.string
}

FileUploader.defaultProps = {
  uploadFn: null,
  square: false,
  dispatchFn: null,
  theme: null,
  tooltip: '',
  formClasses: '',
  size: 'small'
}

export default withNamespaces('common')(FileUploader)
