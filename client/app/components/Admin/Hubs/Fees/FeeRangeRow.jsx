import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import styles from './index.scss'
import PropTypes from '../../../../prop-types'
// import { gradientCSSGenerator } from '../../../../helpers'
import { NamedSelect } from '../../../NamedSelect/NamedSelect'
import {
  chargeGlossary,
  rateBasises,
  moment
} from '../../../../constants'
import AdminPromptConfirm from '../../Prompt/Confirm'

class FeeRangeRow extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      edit: props.initialEdit || false
    }
  }
  toggleEdit () {
    this.setState({ edit: !this.state.edit }, () => this.props.isEditing())
  }
  confirmDelete () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }
  confirmSave (target) {
    this.setState({ confirm: true })
  }
  closeAndSave () {
    const { target, saveEdit } = this.props
    saveEdit(target)
    this.closeConfirm()
    this.toggleEdit()
  }
  renderFeeBoxes (fee, editCharge, selectOptions, edit) {
    const {
      handleSelect, handleChange, target, direction
    } = this.props
    const dnrKeys = ['currency', 'rate_basis', 'key', 'name', 'range']
    let feeKeys = []
    switch (fee.rate_basis) {
      case 'PER_SHIPMENT' || 'PER_BILL' || 'PER_ITEM' || 'PER_CONTAINER' || 'PER_WM':
        feeKeys = ['rate', 'min']
        break
      case 'PER_CBM':
        feeKeys = ['cbm', 'min']
        break
      case 'PER_KG':
        feeKeys = ['kg', 'min']
        break
      case 'PER_CBM_TON':
        feeKeys = ['cbm', 'ton', 'min']
        break
      case 'PER_TON':
        feeKeys = ['ton', 'min']
        break
      case /RANGE/:
        break
      default:
        feeKeys = ['rate', 'min']
        break
    }
    const cells = []
    const rbCell = edit ? (<div
      className={`flex layout-row layout-align-none-center layout-wrap ${
        styles.price_cell
      }`}
    >
      <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary.rate_basis}</p>
      <NamedSelect
        name={`${direction}-${fee.key}-${'rate_basis'}`}
        classes={`${styles.select}`}
        value={selectOptions ? selectOptions[direction][fee.key].rate_basis : ''}
        options={rateBasises}
        className="flex-100"
        onChange={e => handleSelect(e, target)}
      />
    </div>) : (<div
      className={`flex-25 layout-row layout-align-none-center layout-wrap ${
        styles.price_cell
      }`}
    >
      <p className={`flex-90 ${styles.price_cell_data}`}>
        {chargeGlossary[fee.rate_basis]}
      </p>
      <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary.rate_basis}</p>
      <div className={`flex-none ${styles.price_cell_divider}`} />
    </div>)
    cells.push(rbCell)
    feeKeys.forEach((chargeKey, i) => {
      if (!dnrKeys.includes(chargeKey)) {
        const cell = edit ? (<div
          key={chargeKey}
          className={`flex layout-row layout-align-none-center layout-wrap ${
            styles.price_cell
          }`}
        >
          <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[chargeKey]}</p>
          <div className="flex-95 layout-row input_box_full">
            <input
              type="number"
              value={editCharge.fees[fee.key][chargeKey]}
              onChange={e => handleChange(e, target)}
              name={`${direction}-${fee.key}-${chargeKey}`}
            />
          </div>
          {i !== feeKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
        </div>) : (<div
          className={`flex-25 layout-row layout-align-none-center layout-wrap ${
            styles.price_cell
          }`}
        >
          <p className={`flex-90 ${styles.price_cell_data}`}>
            {fee[chargeKey]} {fee.currency}
          </p>
          <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[chargeKey]}</p>
          {i !== feeKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
        </div>)
        cells.push(cell)
      }
    })

    return cells
  }
  renderRangeFeeBoxes (rangeFee, index, editCharge, fee, edit) {
    const {
      handleRangeChange, target, direction
    } = this.props
    const feeKeys = ['min', 'max', 'rate']
    const cells = []
    feeKeys.forEach((chargeKey, i) => {
      const cell = edit ? (<div
        key={chargeKey}
        className={`flex-25 layout-row layout-align-none-center layout-wrap ${
          styles.price_cell
        }`}
      >
        <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[chargeKey]}</p>
        <div className="flex-95 layout-row input_box_full">
          <input
            type="number"
            step="0.01"
            value={editCharge.fees[fee.key].range[index][chargeKey]}
            onChange={e => handleRangeChange(e, target)}
            name={`${direction}-${fee.key}-${index}-${chargeKey}`}
          />
        </div>
        {i !== feeKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
      </div>) : (<div
        className={`flex-25 layout-row layout-align-none-center layout-wrap ${
          styles.price_cell
        }`}
      >
        <p className={`flex-90 ${styles.price_cell_data}`}>
          {rangeFee[chargeKey]} {chargeKey === 'rate' ? fee.currency : 'kg'}
        </p>
        <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[chargeKey]}</p>
        {i !== feeKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
      </div>)
      cells.push(cell)
    })

    return cells
  }
  renderDateBoxes (fee, editCharge, edit) {
    const { handleDateEdit } = this.props
    const dateKeys = ['effective_date', 'expiration_date']
    const cells = []

    const dayPickerProps = {
      disabledDays: {
        before: new Date(moment()
          .add(7, 'days')
          .format())
      },
      month: new Date(
        moment()
          .add(7, 'days')
          .format('YYYY'),
        moment()
          .add(7, 'days')
          .format('M') - 1
      ),
      name: 'dayPicker'
    }
    dateKeys.forEach((dk, i) => {
      const dateCell = edit ? (<div
        className={`flex layout-row layout-align-none-center layout-wrap ${
          styles.price_cell
        } ${styles.dpb}`}
      >
        <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[dk]}</p>
        <DayPickerInput
          name="dayPicker"
          placeholder="DD/MM/YYYY"
          format="DD/MM/YYYY"
          value={editCharge.fees[fee.key][dk]}
          onDayChange={e => handleDateEdit(e, dk)}
          dayPickerProps={dayPickerProps}
        />
        {i !== dateKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
      </div>) : (<div
        className={`flex layout-row layout-align-none-center layout-wrap ${
          styles.price_cell
        }`}
      >
        <p className={`flex-90 ${styles.price_cell_label}`}>{chargeGlossary[dk]}</p>
        <p className={`flex-90 ${styles.price_cell_data}`}>{moment(fee[dk]).format('ll')}</p>
        {i !== dateKeys.length - 1 ? <div className={`flex-none ${styles.price_cell_divider}`} /> : ''}
      </div>)
      cells.push(dateCell)
    })

    return cells
  }

  render () {
    const { edit, confirm } = this.state
    const {
      t, fee, theme, selectOptions, editCharge, initialEdit
    } = this.props
    if (!selectOptions) {
      return ''
    }
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={t('admin:instantlyAvailable')}
        confirm={() => this.closeAndSave()}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const startEdit = (<div className="flex-15 layout-row layout-align-center-center" onClick={() => this.toggleEdit()}>
      <i className="fa fa-edit" />
    </div>)
    const endEdit = (<div className="flex-15 layout-column layout-align-space-around-center" >
      <div className={`flex-50 layout-row layout-align-center-center ${styles.edit_icon_wrapper} ${styles.save_icon}`} onClick={() => this.confirmSave()}>
        <i className="fa fa-floppy-o" />
      </div>
      <div className={`flex-50 layout-row layout-align-center-center ${styles.edit_icon_wrapper} ${styles.close_icon}`} onClick={() => this.toggleEdit()}>
        <i className="fa fa-times" />
      </div>
    </div>)
    const rangeRows = fee.range.map((rFee, index) => (
      <div className="flex-100 layout-row layout-align-end-center">
        {this.renderRangeFeeBoxes(rFee, index, editCharge, fee, edit)}
      </div>
    ))

    return (
      <div
        className={`${styles.fee_row} flex-100 layout-row layout-align-center-center layout-wrap`}
      >
        { confimPrompt }
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-20 layout-row layout-align-start-center">
            <p className="flex-none offset-5">{ `${fee.key} - ${fee.name}`}</p>
          </div>
          <div className="flex-50 layout-row layout-align-end-center">
            {this.renderFeeBoxes(fee, editCharge, selectOptions, edit)}
          </div>
          <div className="flex-30 layout-row ">
            <div className="flex-85 layout-row">
              {this.renderDateBoxes(fee, editCharge, edit)}
            </div>
            { !initialEdit ? <div className="flex-15 layout-row layout-align-center-center" >
              { edit ? endEdit : startEdit }
            </div> : ''}
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-end-center layout-wrap" />
        {rangeRows}
      </div>
    )
  }
}

FeeRangeRow.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme.isRequired,
  target: PropTypes.string.isRequired,
  saveEdit: PropTypes.func.isRequired,
  handleSelect: PropTypes.func.isRequired,
  handleChange: PropTypes.func.isRequired,
  handleRangeChange: PropTypes.func.isRequired,
  handleDateEdit: PropTypes.func.isRequired,
  editCharge: PropTypes.objectOf(PropTypes.any).isRequired,
  direction: PropTypes.string.isRequired,
  fee: PropTypes.objectOf(PropTypes.any).isRequired,
  selectOptions: PropTypes.objectOf(PropTypes.any).isRequired,
  isEditing: PropTypes.func.isRequired,
  initialEdit: PropTypes.bool
}
FeeRangeRow.defaultProps = {
  initialEdit: false
}
export default withNamespaces(['admin', 'common'])(FeeRangeRow)
