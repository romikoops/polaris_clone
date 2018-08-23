import React from 'react'
import fetch from 'isomorphic-fetch'
import { Link } from 'react-router-dom'
import Truncate from 'react-truncate'
import { Promise } from 'es6-promise-promise'
import PropTypes from '../../prop-types'
import { authHeader } from '../../helpers'
import styles from './FileTile.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { BASE_URL, moment, documentTypes } from '../../constants'
import { ROW, WRAP_ROW, trim, ALIGN_CENTER, ALIGN_END } from '../../classNames'

const CONTAINER = `FILE_TILE ${WRAP_ROW('none')} layout-align-center-start ${styles.tile}`
const CHECK_ICON = 'clip fa fa-check'
const EYE_ICON = 'clip fa fa-eye'
const PENCIL_ICON = 'fa fa-pencil clip'
const TRASH_ICON = 'clip fa fa-trash'
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
      denial: {},
      file: null,
      showDenialDetails: false
    }
    this.deleteFile = this.deleteFile.bind(this)
    this.fileUpload = this.fileUpload.bind(this)
    this.handleApprove = this.handleApprove.bind(this)
    this.handleDenialForm = this.handleDenialForm.bind(this)
    this.handleDeny = this.handleDeny.bind(this)
    this.onChange = this.onChange.bind(this)
    this.onFormSubmit = this.onFormSubmit.bind(this)
    this.toggleShowDenial = this.toggleShowDenial.bind(this)
  }
  onFormSubmit (e) {
    e.preventDefault() // Stop form submit
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
    if (!file) return ''

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
    const uploadUrl = BASE_URL + url

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
    const { showDenialDetails, denial } = this.state
    const {
      theme,
      type,
      doc,
      isAdmin
    } = this.props

    const clickUploaderInput = () => {
      this.uploaderInput.click()
    }
    const textStyle = textStyleFn(theme)
    const statusStyle = statusStyleFn(doc)

    const LinkComponent = () => {
      if (!doc.signed_url) return ''

      return (
        <Link
          className={`${ROW('none')} ${ALIGN_CENTER}`}
          target="_blank"
          to={doc.signed_url}
        >
          <i className={EYE_ICON} style={textStyle} />
        </Link>
      )
    }

    const denyDetails = (
      <div className={`${ROW('none')} ${ALIGN_CENTER} ${styles.backdrop}`}>
        <div className={`flex-none ${styles.fade}`} onClick={this.toggleShowDenial} />
        <div className={`${WRAP_ROW('none')} layout-align-center-start  ${styles.content}`}>
          <div className={`${ROW(100)} layout-align-start-center`}>
            <h3 className="flex-none clip" style={textStyle}>
              Reject document
            </h3>
          </div>

          <div className={`${ROW(100)} layout-align-start-center ${styles.input_box}`}>
            <textarea
              rows="4"
              className="flex-100"
              value={denial.text}
              onChange={this.handleDenialForm}
            />
          </div>

          <div className={`${ROW(100)} ${ALIGN_END}`}>
            <div className={ROW('none')} style={{ margin: '15px' }}>
              <RoundButton
                theme={theme}
                size="small"
                text="Deny"
                iconClass="fa-times"
                handleNext={this.handleDeny}
              />
            </div>
          </div>
        </div>
      </div>
    )

    const userRow = (
      <div className={`${ROW(100)} layout-align-center-end`}>
        <div className={`${styles.upload_btn_wrapper} ${ROW(33)} ${ALIGN_CENTER}`}>
          <form
            className={`${ROW('none')} ${ALIGN_CENTER}`}
            onSubmit={this.onFormSubmit}
          >
            <div className="flex-none" onClick={clickUploaderInput}>
              <i className={PENCIL_ICON} style={textStyle} />
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

        <div className={`${styles.upload_btn_wrapper} ${ROW('33')} ${ALIGN_CENTER}`}>
          <div
            className={`${ROW('none')} ${ALIGN_CENTER}`}
            onClick={this.deleteFile}
          >
            <i className={TRASH_ICON} style={textStyle} />
          </div>
        </div>
        <div className={`${styles.upload_btn_wrapper} ${ROW(33)} ${ALIGN_CENTER}`}>
          {LinkComponent()}
        </div>
      </div>
    )

    const adminRow = (
      <div className={`${ROW(100)} layout-align-center-end`}>
        <div className={`${styles.upload_btn_wrapper} ${ROW(33)} ${ALIGN_CENTER}`}>
          <div
            className={`${ROW('none')} ${ALIGN_CENTER}`}
            onClick={this.handleApprove}
          >
            <i className={CHECK_ICON} style={textStyle} />
          </div>
        </div>
        <div className={`${styles.upload_btn_wrapper} ${ROW(33)} ${ALIGN_CENTER}`}>
          <div className={`${ROW('none')} ${ALIGN_CENTER}`} onClick={this.toggleShowDenial}>
            <i className="fa fa-times" style={{ color: 'red' }} />
          </div>
        </div>
        <div className={`${styles.upload_btn_wrapper} ${ROW(33)} ${ALIGN_CENTER}`}>
          {LinkComponent()}
        </div>
      </div>
    )
    const bottomRow = isAdmin ? adminRow : userRow

    return (
      <div className={CONTAINER}>
        {showDenialDetails ? denyDetails : ''}
        <div className={`${WRAP_ROW(100)} ${ALIGN_CENTER}`}>
          <div className={`${WRAP_ROW(100)} layout-align-center-start`}>
            <div className={trim(`
                ${WRAP_ROW(100)}
                layout-align-center-start 
                ${styles.file_header}
              `)}
            >
              <p className="flex-100">Title</p>
            </div>
            <div className={trim(`
                ${WRAP_ROW(100)}
                layout-align-center-start 
                ${styles.file_text}
              `)}
            >
              <p className="flex-100">
                <Truncate lines={1}>{doc.text} </Truncate>
              </p>
            </div>
          </div>

          <div className={`${WRAP_ROW(100)} layout-align-center-start`}>
            <div className={trim(`
                ${WRAP_ROW(100)}
                layout-align-center-start 
                ${styles.file_header}
              `)}
            >
              <p className="flex-100">Type</p>
            </div>

            <div
              className={trim(`
                ${WRAP_ROW(100)}
                layout-align-center-start
                ${styles.file_text}
              `)}
            >
              <p className="flex-100">{docTypes[doc.doc_type]}</p>
            </div>
          </div>
          <div className={`${WRAP_ROW(100)} layout-align-center-start`}>
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.file_header
              }`}
            >
              <p className="flex-100">Uploaded</p>
            </div>
            <div className={trim(`
                ${WRAP_ROW(100)}
                layout-align-center-start 
                ${styles.file_text}
              `)}
            >
              <p className="flex-100">{moment(doc.created_at).format('lll')}</p>
            </div>
          </div>
          <div className={`${WRAP_ROW(100)} layout-align-center-start`}>
            <div className={`${WRAP_ROW(100)} layout-align-center-start ${styles.file_header}`}>
              <p className="flex-100">Status</p>
            </div>
            <div
              className={trim(`
                ${WRAP_ROW(100)}
                layout-align-center-start 
                  ${styles.file_text}
                ${statusStyle}
              `)}
            >
              <p className="flex-100">{doc.approved ? doc.approved : 'Pending'}</p>
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

function textStyleFn (theme) {
  return {
    background:
      theme && theme.colors
        ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
        : 'black'
  }
}

function statusStyleFn (doc) {
  if (doc.approved === 'approved') {
    return styles.approved
  } else if (doc.approved === 'rejected') {
    return styles.rejected
  } else if (doc.approved === null) {
    return styles.pending
  }

  return undefined
}

export default FileTile
