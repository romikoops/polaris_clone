import React from 'react'
import fetch from 'isomorphic-fetch'
import { Promise } from 'es6-promise-promise'
import PropTypes from '../../prop-types'
import { BASE_URL } from '../../constants'
import { authHeader } from '../../helpers'
import styles from './FileUploader.scss'
import { RoundButton } from '../RoundButton/RoundButton'

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
      file: null
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
  }

  render () {
    const clickUploaderInput = () => {
      this.uploaderInput.click()
    }
    const { theme, type } = this.props
    return (
      <div className={styles.upload_btn_wrapper}>
        <form onSubmit={this.onFormSubmit}>
          <RoundButton
            text="Upload"
            theme={theme}
            size="small"
            handleNext={clickUploaderInput}
            active
          />
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
  type: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  dispatchFn: PropTypes.func,
  uploadFn: PropTypes.func
}

FileUploader.defaultProps = {
  uploadFn: null,
  dispatchFn: null,
  theme: null
}

export default FileUploader
