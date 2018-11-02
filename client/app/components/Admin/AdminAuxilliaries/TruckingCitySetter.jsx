import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import FormsyInput from '../../FormsyInput/FormsyInput'
import GmapsWrapper from '../../../hocs/GmapsWrapper'
import PlaceSearch from '../../Maps/PlaceSearch'
import { RoundButton } from '../../RoundButton/RoundButton'

export const TruckingCitySetter = ({
  newCell, theme, addNewCell, handlePlaceChange, tmpCity, t
}) => (
  <div className="flex-100 layout-row layout-align-start-center">
    <Formsy onValidSubmit={addNewCell} className="flex-100 layout-row layout-align-start-center">
      <div className="flex-66 layout-row layout-wrap">
        <h3 className="flex-40">{t('admin:findCities')}</h3>
        {tmpCity.city ? (
          <div className="flex-55 layout-row layout-align-start-center input_box">
            <FormsyInput
              type="text"
              name="city"
              value={tmpCity.city}
              placeholder={t('user:city')}
            />
            <FormsyInput
              type="text"
              name="country"
              value={tmpCity.country}
              placeholder={t('user:country')}
            />
          </div>
        ) : (
          <div className="offset-5 flex-55">
            <GmapsWrapper
              theme={theme}
              component={PlaceSearch}
              inputStyles={{
                width: '96%',
                marginTop: '9px',
                background: 'white'
              }}
              options={{ types: ['(cities)'] }}
              handlePlaceChange={handlePlaceChange}
              hideMap
            />
          </div>
        )}
      </div>
      <div className="flex-33 layout-row layout-align-center-center">
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
TruckingCitySetter.propTypes = {
  theme: PropTypes.theme,
  newCell: PropTypes.objectOf(PropTypes.any).isRequired,
  tmpCity: PropTypes.objectOf(PropTypes.any),
  addNewCell: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired,
  handlePlaceChange: PropTypes.func.isRequired
}
TruckingCitySetter.defaultProps = {
  theme: {},
  tmpCity: {}
}
export default withNamespaces(['user', 'admin'])(TruckingCitySetter)
