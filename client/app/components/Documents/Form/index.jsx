import React from 'react'
import { withNamespaces } from 'react-i18next'
import fetch from 'isomorphic-fetch'
import Truncate from 'react-truncate'
import { Promise } from 'es6-promise-promise'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import getApiHost from '../../../constants/api.constants'
import { authHeader, gradientTextGenerator } from '../../../helpers'
import styles from './index.scss'
import AdminPromptConfirm from '../../Admin/Prompt/Confirm'

class DocumentsForm extends React.Component {
  static handleResponse (response) {
    if (!response.ok) {
      return Promise.reject(response.statusText)
    }

    return response.json()
  }

  static downloadFile (url) {
    window.location = url
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

      return fetch(uploadUrl, requestOptions).then(DocumentsForm.handleResponse)
    }
    if (this.uploaderInput.files.length) {
      this.uploaderInput.value = ''
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
  confirmDelete (doc) {
    this.setState({ docToDelete: doc, showConfirm: true })
  }
  toggleShowConfim () {
    this.setState(prevState => ({ showConfirm: !prevState.showConfirm }))
  }
  deleteFile (e) {
    e.preventDefault()
    const { deleteFn } = this.props
    const { docToDelete } = this.state
    if (this.uploaderInput.files.length) {
      this.uploaderInput.value = ''
    }
    this.setState({ file: null })
    deleteFn(docToDelete)
    this.toggleShowConfim()
  }
  render () {
    const {
      theme,
      type,
      tooltip,
      text,
      doc,
      isRequired,
      displayOnly,
      multiple,
      viewer,
      t
    } = this.props
    const { showConfirm } = this.state
    const tooltipId = v4()
    const errorStyle = this.state.error ? styles.error : ''
    const fileName = doc ? (
      <p className="flex-none pointy" onClick={() => DocumentsForm.downloadFile(doc.signed_url)}>
        <Truncate lines={1}>{doc.text} </Truncate>
      </p>
    ) : (
      ''
    )
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const link = doc.signed_url ? (
      <a
        href={doc.signed_url}
        className={`${styles.icon_btn} flex-none layout-row layout-align-center-center`}
        target="_blank"
      >
        <i className="clip fa fa-eye" style={textStyle} />
      </a>
    ) : (
      ''
    )
    const missingFile = isRequired ? (
      <p className={`${styles.missing}`}>
        <i className="fa fa-exclamation-triangle" />
        {t('doc:missingFile')}
      </p>
    ) : (
      <p className={`${styles.optional}`}>
        <i className="fa fa-exclamation-triangle" />
        {t('common:optional')}
      </p>
    )
    const iconRowStyle = viewer && !multiple ? styles.viewer_row : styles.icon_row
    const confirmModal = showConfirm
      ? (<AdminPromptConfirm
        theme={theme}
        heading={t('doc:deleteThisDoc')}
        text={t('doc:areYouSure')}
        confirm={() => this.deleteFile()}
        deny={() => this.toggleShowConfim()}
      />) : ''

    return (
      <div
        className={`${styles.form} flex-100 layout-row
        layout-align-none-center layout-wrap`}
      >
        {confirmModal}
        <div className="flex layout-row layout-wrap">
          <div className={`${styles.form_label} flex-40 layout-row
          layout-align-start-center`}
          >
            <p className="flex-none">{text}</p>
          </div>
          <div className="flex-60 layout-row layout-align-center-center">
            {doc ? fileName : missingFile}
          </div>
        </div>
        <div className={`${iconRowStyle} flex-none layout-row layout-align-none-center`}>
          {displayOnly ? (
            <div className={`${styles.icon_btn} flex-none layout-row
            layout-align-center-center`}
            />
          ) : (
            <div
              className={`flex-none layout-row layout-align-end-center ${
                styles.upload_btn_wrapper
              } `}
              data-tip={tooltip}
              data-for={tooltipId}
            >
              <form>
                <button
                  className={`${styles.icon_btn} flex-none layout-row
                    layout-align-center-center`}
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
          )}
          {multiple ? (
            <div className={`${styles.icon_btn} flex-none layout-row
            layout-align-center-center`}
            />
          ) : (
            <div
              className={`${styles.icon_btn} flex-none layout-row
              layout-align-center-center`}
              onClick={() => this.confirmDelete(doc)}
            >
              <i className="fa fa-trash" />
            </div>
          )}
          {viewer && !multiple ? (
            link
          ) : (
            <div className={`${styles.icon_btn} flex-none
            layout-row layout-align-center-center`}
            />
          )}
        </div>
        <div
          className={`${styles.file_error} ${errorStyle} flex-100
          layout-row layout-align-center`}
        >
          <p className="flex-100">
            {t('doc:restrictions')}
          </p>
        </div>
      </div>
    )
  }
}

DocumentsForm.propTypes = {
  url: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  dispatchFn: PropTypes.func,
  uploadFn: PropTypes.func,
  tooltip: PropTypes.string,
  text: PropTypes.string,
  doc: PropTypes.objectOf(PropTypes.any),
  isRequired: PropTypes.bool,
  deleteFn: PropTypes.func,
  displayOnly: PropTypes.bool,
  multiple: PropTypes.bool,
  viewer: PropTypes.bool
}

DocumentsForm.defaultProps = {
  uploadFn: null,
  dispatchFn: null,
  theme: null,
  tooltip: '',
  text: '',
  doc: {},
  isRequired: false,
  deleteFn: null,
  displayOnly: false,
  multiple: false,
  viewer: false
}

export default withNamespaces(['common', 'doc'])(DocumentsForm)
