import React from 'react'
import { withNamespaces } from 'react-i18next'
import fetch from 'isomorphic-fetch'
import Truncate from 'react-truncate'
import { Promise } from 'es6-promise-promise'
import ReactTooltip from 'react-tooltip'

import { Link } from 'react-router-dom'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import getApiHost from '../../../constants/api.constants'
import { authHeader, gradientTextGenerator } from '../../../helpers'
import styles from './index.scss'

class DocumentsMultiForm extends React.Component {
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
    if (
      fileExt === 'docx' ||
      fileExt === 'doc' ||
      fileExt === 'jpeg' ||
      fileExt === 'jpg' ||
      fileExt === 'tiff' ||
      fileExt === 'png' ||
      fileExt === 'xls' ||
      fileExt === 'xlsx' ||
      fileExt === 'pdf'
    ) {
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
      const uploadUrl = getApiHost() + url
      return fetch(uploadUrl, requestOptions).then(DocumentsMultiForm.handleResponse)
    }
    return this.showFileTypeError()
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
      theme,
      type,
      tooltip,
      text,
      documents,
      deleteFn,
      t
    } = this.props
    const tooltipId = v4()
    const errorStyle = this.state.error ? styles.error : ''
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    const existingDocuments = documents
      ? documents.map((d) => {
        const link = d.signed_url ? (
          <Link
            to={d.signed_url}
            className={`${styles.icon_btn} flex layout-row layout-align-center-center`}
            target="_blank"
          >
            <p className="flex">
              <Truncate lines={1}>{d.text} </Truncate>
            </p>
          </Link>
        ) : (
          <p className="flex">
            <Truncate lines={1}>{d.text} </Truncate>
          </p>
        )

        return (
          <div className="flex-100 layout-row layout-align-start-center">
            {link}
            <div
              className={`${styles.icon_btn} flex-none layout-row layout-align-center-center`}
              onClick={() => deleteFn(d)}
            >
              <i className="fa fa-trash pointy" />
            </div>
          </div>)
      })
      : []
    const heightVal = existingDocuments.length * 35 + 35

    return (
      <div className={`${styles.form} flex-100 layout-row layout-align-none-center layout-wrap`} style={{ height: `${heightVal}px` }}>
        <div className={`${styles.form_label} flex-40 layout-row layout-align-start-center`}>
          <p className="flex-none">{text}</p>
        </div>
        <div className="flex-60 layout-row layout-align-center-center layout-wrap">
          {existingDocuments}
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex">{t('doc:uploadAnother')}</p>
            <div
              className={`flex-none layout-row layout-align-end-center ${
                styles.upload_btn_wrapper
              } `}
              data-tip={tooltip}
              data-for={tooltipId}
            >
              <form >
                <button
                  className={`${styles.icon_btn} flex-none layout-row layout-align-center-center`}
                  onClick={e => this.clickUploaderInput(e)}
                >
                  <i className="fa fa-upload clip" style={textStyle} />
                </button>
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
          </div>
        </div>
        <div
          className={`${styles.file_error} ${errorStyle} flex-100 layout-row layout-align-center`}
        >
          <p className="flex-100">{t('doc:restrictions')}</p>
        </div>
      </div>
    )
  }
}

DocumentsMultiForm.propTypes = {
  url: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  dispatchFn: PropTypes.func,
  uploadFn: PropTypes.func,
  tooltip: PropTypes.string,
  text: PropTypes.string,
  documents: PropTypes.arrayOf(PropTypes.any),
  deleteFn: PropTypes.func
}

DocumentsMultiForm.defaultProps = {
  uploadFn: null,
  dispatchFn: null,
  theme: null,
  tooltip: '',
  text: '',
  documents: [],
  deleteFn: null
}

export default withNamespaces('doc')(DocumentsMultiForm)
