import React from 'react'
import { withNamespaces } from 'react-i18next'
import fetch from 'isomorphic-fetch'
import { Link } from 'react-router-dom'
import Truncate from 'react-truncate'
import { Promise } from 'es6-promise-promise'
import PropTypes from '../../prop-types'
import { authHeader } from '../../helpers'
import styles from './FileTile.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { moment, documentTypes } from '../../constants'
import getApiHost from '../../constants/api.constants'

const docTypes = documentTypes
class FileTile extends React.Component {
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
      denial: {},
      showDenialDetails: false
    }
    this.onFormSubmit = this.onFormSubmit.bind(this)
    this.onChange = this.onChange.bind(this)
    this.fileUpload = this.fileUpload.bind(this)
    this.deleteFile = this.deleteFile.bind(this)
    this.toggleShowDenial = this.toggleShowDenial.bind(this)
    this.handleDeny = this.handleDeny.bind(this)
    this.handleApprove = this.handleApprove.bind(this)
    this.handleDenialForm = this.handleDenialForm.bind(this)
  }
  onFormSubmit (e) {
    e.preventDefault()
    this.fileUpload(this.state.file)
  }
  onChange (e) {
    this.fileUpload(e.target.files[0])
  }
  deleteFile () {
    const { doc, deleteFn } = this.props
    deleteFn(doc.id)
  }
  handleDenialForm (ev) {
    const { value } = ev.target
    this.setState({ denial: { text: value } })
  }
  fileUpload (file) {
    const { type, dispatchFn, doc } = this.props
    const url = `/shipments/${doc.shipment_id}/upload/${doc.doc_type}`
    if (!file) {
      return ''
    }
    if (dispatchFn) {
      return dispatchFn(file)
    }
    const formData = new window.FormData()
    formData.append('file', file)
    formData.append('type', type)
    const requestOptions = {
      method: 'POST',
      headers: { ...authHeader() },
      body: formData
    }
    if (this.uploaderInput.files.length) {
      this.uploaderInput.value = ''
    }
    const uploadUrl = getApiHost() + url

    return fetch(uploadUrl, requestOptions).then(FileTile.handleResponse)
  }
  handleDeny () {
    const { doc, adminDispatch } = this.props
    const { denial } = this.state
    denial.type = 'reject'
    adminDispatch.documentAction(doc.id, denial)
    this.toggleShowDenial()
  }
  handleApprove () {
    const { doc, adminDispatch } = this.props
    const { denial } = this.state
    denial.type = 'approve'
    adminDispatch.documentAction(doc.id, denial)
  }
  toggleShowDenial () {
    this.setState({ showDenialDetails: !this.state.showDenialDetails })
  }

  render () {
    const clickUploaderInput = () => {
      this.uploaderInput.click()
    }
    const {
      theme, type, doc, isAdmin, t
    } = this.props
    const { showDenialDetails, denial } = this.state
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    let statusStyle
    if (doc.approved === 'approved') {
      statusStyle = styles.approved
    } else if (doc.approved === 'rejected') {
      statusStyle = styles.rejected
    } else if (doc.approved === null) {
      statusStyle = styles.pending
    }
    const link = doc.signed_url ? (
      <Link
        to={doc.signed_url}
        className="flex-none layout-row layout-align-center-center"
        target="_blank"
      >
        <i className="clip fa fa-eye" style={textStyle} />
      </Link>
    ) : (
      ''
    )
    const denyDetails = (
      <div className={`flex-none layout-row layout-align-center-center  ${styles.backdrop}`}>
        <div className={`flex-none ${styles.fade}`} onClick={this.toggleShowDenial} />
        <div
          className={`flex-none layout-row layout-wrap layout-align-center-start  ${
            styles.content
          }`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <h3 className="flex-none clip" style={textStyle}>
              {t('doc:reject')}
            </h3>
          </div>
          <div className={`flex-100 layout-row layout-align-start-center ${styles.input_box}`}>
            <textarea
              rows="4"
              className="flex-100"
              value={denial.text}
              onChange={this.handleDenialForm}
            />
          </div>
          <div className="flex-100 layout-row layout-align-end-end">
            <div className="flex-none layout-row" style={{ margin: '15px' }}>
              <RoundButton
                theme={theme}
                size="small"
                text={t('common:deny')}
                iconClass="fa-times"
                handleNext={this.handleDeny}
              />
            </div>
          </div>
        </div>
      </div>
    )
    const userRow = (
      <div className="flex-100 layout-row layout-align-center-end">
        <div
          className={`${styles.upload_btn_wrapper} flex-33 layout-row layout-align-center-center`}
        >
          <form
            className="flex-none layout-row layout-align-center-center"
            onSubmit={this.onFormSubmit}
          >
            <div className="flex-none" onClick={clickUploaderInput}>
              <i className="fa fa-pencil clip" style={textStyle} />
            </div>
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
        <div
          className={`${styles.upload_btn_wrapper} flex-33 layout-row layout-align-center-center`}
        >
          <div
            className="flex-none layout-row layout-align-center-center"
            onClick={this.deleteFile}
          >
            <i className="clip fa fa-trash" style={textStyle} />
          </div>
        </div>
        <div
          className={`${styles.upload_btn_wrapper} flex-33 layout-row layout-align-center-center`}
        >
          {link}
        </div>
      </div>
    )
    const adminRow = (
      <div className="flex-100 layout-row layout-align-center-end">
        <div
          className={`${styles.upload_btn_wrapper} flex-33 layout-row layout-align-center-center`}
        >
          <div
            className="flex-none layout-row layout-align-center-center"
            onClick={this.handleApprove}
          >
            <i className="clip fa fa-check" style={textStyle} />
          </div>
        </div>
        <div
          className={`${styles.upload_btn_wrapper} flex-33 layout-row layout-align-center-center`}
        >
          <div
            className="flex-none layout-row layout-align-center-center"
            onClick={this.toggleShowDenial}
          >
            <i className=" fa fa-times" style={{ color: 'red' }} />
          </div>
        </div>
        <div
          className={`${styles.upload_btn_wrapper} flex-33 layout-row layout-align-center-center`}
        >
          {link}
        </div>
      </div>
    )
    const bottomRow = isAdmin ? adminRow : userRow

    return (
      <div className={`flex-none layout-row layout-wrap layout-align-center-start ${styles.tile} `}>
        {showDenialDetails ? denyDetails : ''}
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">
          <div className="flex-100 layout-row layout-wrap layout-align-center-start">
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.file_header
              }`}
            >
              <p className="flex-100">{t('common:title')}</p>
            </div>
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.file_text
              }`}
            >
              <p className="flex-100">
                <Truncate lines={1}>{doc.text} </Truncate>
              </p>
            </div>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-center-start">
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.file_header
              }`}
            >
              <p className="flex-100">{t('doc:type')}</p>
            </div>
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.file_text
              }`}
            >
              <p className="flex-100">{docTypes[doc.doc_type]}</p>
            </div>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-center-start">
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.file_header
              }`}
            >
              <p className="flex-100">{t('doc:uploaded')}</p>
            </div>
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.file_text
              }`}
            >
              <p className="flex-100">{moment(doc.created_at).format('lll')}</p>
            </div>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-center-start">
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.file_header
              }`}
            >
              <p className="flex-100">{t('common:status')}</p>
            </div>
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.file_text
              } ${statusStyle}`}
            >
              <p className="flex-100">{doc.approved ? doc.approved : t('common:pending')}</p>
            </div>
          </div>
        </div>
        {bottomRow}
      </div>
    )
  }
}

FileTile.propTypes = {
  type: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  isAdmin: PropTypes.bool,
  theme: PropTypes.theme,
  dispatchFn: PropTypes.func.isRequired,
  adminDispatch: PropTypes.shape({
    documentAction: PropTypes.func
  }).isRequired,
  doc: PropTypes.shape({
    id: PropTypes.number
  }).isRequired,
  deleteFn: PropTypes.func.isRequired
}

FileTile.defaultProps = {
  theme: null,
  isAdmin: false
}

export default withNamespaces(['common', 'doc'])(FileTile)
