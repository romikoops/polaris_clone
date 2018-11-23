import React from 'react'
import { withNamespaces } from 'react-i18next'
import fetch from 'isomorphic-fetch'
import { Promise } from 'es6-promise-promise'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import { getTenantApiUrl } from '../../../constants/api.constants'
import { authHeader } from '../../../helpers'
import { RoundButton } from '../../RoundButton/RoundButton'
import styles from './index.scss'
import { NamedSelect } from '../../NamedSelect/NamedSelect'

class DocumentsSelector extends React.Component {
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
      error: false,
      selected: false
    }
    this.onFormSubmit = this.onFormSubmit.bind(this)
    this.onChange = this.onChange.bind(this)
    this.fileUpload = this.fileUpload.bind(this)
  }
  componentWillMount () {
    if (this.props.options.length < 1 && !this.state.selected) {
      this.setState({ selected: true })
    }
  }
  componentWillReceiveProps (nextProps) {
    if (this.props.options.length < 1 || (nextProps.options.length < 1 && !this.state.selected)) {
      this.setState({ selected: true })
    }
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
  handleSelected (e) {
    this.setState({ selected: e.value })
  }
  fileUpload (baseFile) {
    const file = baseFile
    const { selected } = this.state
    const {
      url, type, dispatchFn, uploadFn
    } = this.props
    if (!file) {
      return ''
    }
    const fileNameSplit = file.name.split('.')
    const fileExt = fileNameSplit[fileNameSplit.length - 1]
    if (fileExt === 'xlsx' || fileExt === 'xls') {
      if (dispatchFn) {
        if (type) {
          file.doc_type = type
        }
        dispatchFn(file, selected)
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
      const uploadUrl = getTenantApiUrl() + url
      fetch(uploadUrl, requestOptions).then(DocumentsSelector.handleResponse)
      if (this.uploaderInput.files.length) {
        this.uploaderInput.value = ''
      }

      return null
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
      theme, type, tooltip, options, t
    } = this.props
    const { selected } = this.state
    const tooltipId = v4()
    const errorStyle = this.state.error ? styles.error : ''

    return (
      <div
        className={`flex-none layout-row ${styles.upload_btn_wrapper} `}
        data-tip={tooltip}
        data-for={tooltipId}
      >
        {selected || !options ? (
          <form>
            <RoundButton
              text={t('common:upload')}
              theme={theme}
              size="small"
              handleNext={e => this.clickUploaderInput(e)}
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
        ) : (
          <div className="flex-100 layout-row layout-align-center-center">
            <NamedSelect
              theme={theme}
              options={options}
              value={selected}
              className="flex-100"
              clearable={false}
              onChange={e => this.handleSelected(e)}
            />
          </div>
        )}
      </div>
    )
  }
}

DocumentsSelector.propTypes = {
  url: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  dispatchFn: PropTypes.func,
  uploadFn: PropTypes.func,
  tooltip: PropTypes.string,
  options: PropTypes.arrayOf(PropTypes.any)
}

DocumentsSelector.defaultProps = {
  uploadFn: null,
  dispatchFn: null,
  theme: null,
  tooltip: '',
  options: []
}

export default withNamespaces('common')(DocumentsSelector)
