import React from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
// import styles from '../Admin.scss'
// import { NamedSelect } from '../../NamedSelect/NamedSelect'
import FormsyInput from '../../FormsyInput/FormsyInput'
import { RoundButton } from '../../RoundButton/RoundButton'

export function TruckingZipSetter ({ newCell, theme, addNewCell }) {
  return (
    <div className="flex-100 layout-row layout-align-start-center">
      <Formsy
        onValidSubmit={addNewCell}
        className="flex-100 layout-row layout-align-start-center"
      >
        <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-none sup_l">Lower limit zipcode</p>
          </div>
          <div className="flex-100 layout-row layout-align-start-center input_box">
            <FormsyInput
              type="number"
              name="lower_zip"
              value={newCell.lower_zip}
              placeholder="Lower Zip"
            />
          </div>
        </div>
        <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-none sup_l">Upper limit zipcode</p>
          </div>
          <div className="flex-100 layout-row layout-align-start-center input_box">
            <FormsyInput
              type="number"
              name="upper_zip"
              value={newCell.upper_zip}
              placeholder="Upper Zip"
            />
          </div>
        </div>
        <div className="flex-33 layout-row layout-align-center-center" >
          <RoundButton
            theme={theme}
            size="small"
            text="Add another"
            iconClass="fa-plus-square-o"
          />
        </div>
      </Formsy>
    </div>
  )
}
TruckingZipSetter.propTypes = {
  theme: PropTypes.theme,
  newCell: PropTypes.objectOf(PropTypes.any).isRequired,
  addNewCell: PropTypes.func.isRequired
}
TruckingZipSetter.defaultProps = {
  theme: {}
}
export default TruckingZipSetter
