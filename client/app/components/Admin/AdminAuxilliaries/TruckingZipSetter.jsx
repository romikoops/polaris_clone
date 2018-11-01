import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
// import styles from '../Admin.scss'
// import { NamedSelect } from '../../NamedSelect/NamedSelect'
import FormsyInput from '../../FormsyInput/FormsyInput'
import { RoundButton } from '../../RoundButton/RoundButton'

export function TruckingZipSetter ({
  newCell, theme, addNewCell, t
}) {
  return (
    <div className="flex-100 layout-row layout-align-start-center">
      <Formsy
        onValidSubmit={addNewCell}
        className="flex-100 layout-row layout-align-start-center"
      >
        <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-none sup_l">
              {t('admin:lowerLimitZip')}
            </p>
          </div>
          <div className="flex-100 layout-row layout-align-start-center input_box">
            <FormsyInput
              type="number"
              name="lower_zip"
              value={newCell.lower_zip}
              placeholder={t('admin:lowerZip')}
            />
          </div>
        </div>
        <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-none sup_l">
              {t('admin:upperLimitZip')}
            </p>
          </div>
          <div className="flex-100 layout-row layout-align-start-center input_box">
            <FormsyInput
              type="number"
              name="upper_zip"
              value={newCell.upper_zip}
              placeholder={t('admin:upperZip')}
            />
          </div>
        </div>
        <div className="flex-33 layout-row layout-align-center-center" >
          <RoundButton
            theme={theme}
            size="small"
            text={t('admin:addAnother')}
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
  addNewCell: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired
}
TruckingZipSetter.defaultProps = {
  theme: {}
}
export default withNamespaces('admin')(TruckingZipSetter)
