import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, hub } from '../../mock'

import AdminLayoverRow from './AdminLayoverRow'

const schedule = {
  eta: 'ETA',
  etd: 'ETD',
  start_date: 'START_DATE',
  end_date: 'END_DATE'
}

/**
 * In `AdminLayoverRow.jsx` PropTypes.theme.isRequired is changed
 * to PropTypes.theme as otherwise the below tests don't work
 */
const propsBase = {
  theme,
  schedule,
  hub,
  itinerary: {}
}

test('shallow render', () => {
  expect(shallow(<AdminLayoverRow {...propsBase} />)).toMatchSnapshot()
})

test('schedule.eta schedule.etd are falsy', () => {
  const props = {
    ...propsBase,
    schedule: {
      ...schedule,
      eta: null,
      etd: null
    }
  }

  expect(shallow(<AdminLayoverRow {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }

  expect(shallow(<AdminLayoverRow {...props} />)).toMatchSnapshot()
})

test('hub.hub_code is truthy', () => {
  const props = {
    ...propsBase,
    hub: {
      ...hub,
      hub_code: 'HUB_CODE'
    }
  }

  expect(shallow(<AdminLayoverRow {...props} />)).toMatchSnapshot()
})

test('schedule is falsy', () => {
  const props = {
    ...propsBase,
    schedule: null
  }

  expect(shallow(<AdminLayoverRow {...props} />)).toMatchSnapshot()
})
