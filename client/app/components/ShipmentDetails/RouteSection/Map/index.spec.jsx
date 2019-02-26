import * as React from 'react'
import { shallow } from 'enzyme'
import RouteSectionMapContent from '.'
import { theme } from '../../mocks'

class MapMock {
  constructor (x) {
    this.x = x
  }

  bindTo () {
    return this.x
  }

  setContent () {
    return this.x
  }

  addListener () {
    return this.x
  }
}

const gMaps = {
  InfoWindow: MapMock,
  LatLngBounds: MapMock,
  Map: MapMock,
  MapTypeId: { ROADMAP: '' },
  Marker: MapMock,
  Point: MapMock,
  Size: MapMock,
  places: { Autocomplete: MapMock }
}

const propsBase = {
  theme,
  gMaps,
  children: <div id="children" />
}

test('with empty props', () => {
  expect(shallow(<RouteSectionMapContent />)).toMatchSnapshot()
})

test('shallow render', () => {
  expect(shallow(<RouteSectionMapContent {...propsBase} />)).toMatchSnapshot()
})
