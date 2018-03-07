import React from 'react'
import fetch from 'isomorphic-fetch'
import { Promise } from 'es6-promise-promise'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { BASE_URL } from '../../constants'
import { authHeader } from '../../helpers'
import { RoundButton } from '../RoundButton/RoundButton'
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
    e.preventDefault() // Stop form submit
    if (this.state.file) {
      this.fileUpload(this.state.file)
    }
  }
  onChange (e) {
    // this.setState({file: e.target.files[0]});
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
    const fileNameSplit = file.name.split('.')
    const fileExt = fileNameSplit[fileNameSplit.length - 1]
    // if (
    //   fileExt === 'docx' ||
    //   fileExt === 'doc' ||
    //   fileExt === 'jpeg' ||
    //   fileExt === 'jpg' ||
    //   fileExt === 'tiff' ||
    //   fileExt === 'png' ||
    //   fileExt === 'pdf'
    // ) {
    if (dispatchFn) {
      if (type) {
        file.doc_type = type
      }
      return dispatchFn(file)
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
    const uploadUrl = BASE_URL + url
    return fetch(uploadUrl, requestOptions).then(FileUploader.handleResponse)
    // }
    // return this.showFileTypeError()
  }
  showFileTypeError () {
    this.setState({ error: true })
    this.alertTimeout = setTimeout(() => this.setState({ error: false }), 5000)
  }
  render () {
    const clickUploaderInput = () => {
      this.uploaderInput.click()
    }
    const { theme, type, tooltip } = this.props
    const tooltipId = v4()
    const errorStyle = this.state.error ? styles.error : ''
    return (
      <div className={`flex-none layout-row ${styles.upload_btn_wrapper} `} data-tip={tooltip} data-for={tooltipId}>
        <form onSubmit={this.onFormSubmit}>
          <RoundButton
            text="Upload"
            theme={theme}
            size="small"
            handleNext={clickUploaderInput}
            active
          />
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
        {/* <div className={`${styles.file_error} ${errorStyle} layout-row layout-align-center`}>
          <p className="flex-100">Only .jpg, .png, .pdf, .tiff, .doc & .docx files allowed</p>
        </div> */}
      </div>
    )
  }
}

FileUploader.propTypes = {
  url: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  dispatchFn: PropTypes.func,
  uploadFn: PropTypes.func,
  tooltip: PropTypes.string
}

FileUploader.defaultProps = {
  uploadFn: null,
  dispatchFn: null,
  theme: null,
  tooltip: ''
}

export default FileUploader
