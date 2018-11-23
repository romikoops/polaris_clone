import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import FormsyTextarea from '../../FormsyTextarea/FormsyTextarea'
import { RoundButton } from '../../RoundButton/RoundButton'
import styles from './AdminSettings.scss'
import CircleCompletion from '../../CircleCompletion/CircleCompletion'
import { remarkActions } from '../../../actions'
import { gradientTextGenerator } from '../../../helpers'

class AdminRemarksEditor extends Component {
  static mapInputs (newRemark) {
    return {
      id: Object.keys(newRemark)[0],
      body: Object.values(newRemark)[0]
    }
  }
  constructor (props) {
    super(props)
    this.state = {
      changedRemarkAttempt: false
    }

    this.saveRemark = this.saveRemark.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.addNewRemark = this.addNewRemark.bind(this)
    this.deleteRemark = this.deleteRemark.bind(this)

    const { remarkDispatch, tenant } = props
    remarkDispatch.getRemarks(tenant)
  }

  componentWillReceiveProps (nextProps) {
    const { remarkDispatch } = this.props

    if (nextProps.remarks.metaData && nextProps.remarks.metaData.savedRemarkSuccess) {
      setTimeout(() => {
        remarkDispatch.updateReduxStore({ metaData: { remarkId: null, savedRemarkSuccess: false } })
      }, 2000)
    }
  }

  saveRemark (newRemark) {
    const { remarkDispatch } = this.props
    remarkDispatch.updateRemarks(newRemark)
  }

  handleInvalidSubmit () {
    if (!this.state.changedRemarkAttempt) this.setState({ changedRemarkAttempt: true })
  }

  addNewRemark () {
    const { remarkDispatch } = this.props
    remarkDispatch.addRemark('quotation', 'shipment', '')
  }

  deleteRemark (remarkId) {
    const { remarkDispatch } = this.props
    remarkDispatch.deleteRemark(remarkId)
  }

  render () {
    const {
      t, theme, remarks
    } = this.props

    const { metaData } = this.props.remarks

    const textStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }

    const NewRemarkButton = (<div className="flex-100">
      <div className="flex-5 layout-row layout-start-start" />
      <div className="layout-row flex-95 layout-wrap layout-align-start-center">
        <div className={`${styles.add_unit_wrapper} content_width`}>
          <div
            className={
              `layout-row flex-none ${styles.add_unit} ` +
            'layout-wrap layout-align-center-center'
            }
            onClick={this.addNewRemark}
          >
            <i className="fa fa-plus-square-o clip" style={textStyle} />
            <p>{t('admin:addRemark')}</p>
          </div>
        </div>
      </div>
    </div>)

    if (!remarks.quotation) {
      return NewRemarkButton
    }
    const AdminRemarkForm = remarks.quotation.shipment.map(remark => (
      <Formsy
        onValidSubmit={this.saveRemark}
        mapping={AdminRemarksEditor.mapInputs}
        onInvalidSubmit={this.handleInvalidSubmit}
        className="flex-100 layout-row layout-align-start-center"
      >
        <div className={`flex-75 layout-align-space-around-start layout-row ${styles.remark_form}`}>
          <div
            className="flex-5 padding_top"
            onClick={() => this.deleteRemark(remark.id)}
          >
            <i className="fa fa-trash" />
          </div>
          <div className="flex-95 layout-align-center-center">
            <FormsyTextarea
              className={styles.remarks}
              rows="10"
              cols="2"
              name={`${remark.id}`}
              value={remark.body}
              submitAttempted={this.state.changedRemarkAttempt}
              required
            />
          </div>
        </div>
        <div className="flex-25 layout-column layout-align-start-center padding_right padding_top" >
          <CircleCompletion
            icon="fa fa-check"
            iconColor={theme.colors.primary || 'green'}
            animated={metaData.savedRemarkSuccess}
            size="50px"
            opacity={metaData.remarkId === remark.id ? '1' : '0'}
          />
          <RoundButton
            theme={theme}
            active
            size="small"
            text={t('common:save')}
          />
        </div>
      </Formsy>
    ))

    return (
      <div>
        {AdminRemarkForm}
        {NewRemarkButton}
      </div>
    )
  }
}

AdminRemarksEditor.propTypes = {
  theme: PropTypes.theme,
  remarks: PropTypes.node,
  tenant: PropTypes.tenant.isRequired,
  remarkDispatch: PropTypes.shape({
    addRemark: PropTypes.func,
    updateRemarks: PropTypes.func,
    getRemarksSuccess: PropTypes.func,
    deleteRemark: PropTypes.func
  }).isRequired,
  savedRemarksSuccess: PropTypes.bool,
  getRemarksSuccess: PropTypes.bool,
  t: PropTypes.func.isRequired
}

AdminRemarksEditor.defaultProps = {
  theme: {},
  remarks: {},
  savedRemarksSuccess: false,
  getRemarksSuccess: false
}

function mapStateToProps (state) {
  return {
    remarks: state.remark
  }
}

function mapDispatchToProps (dispatch) {
  return {
    remarkDispatch: bindActionCreators(remarkActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces('admin')(AdminRemarksEditor))
