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

export const gMaps = {
  InfoWindow: MapMock,
  LatLngBounds: MapMock,
  Map: MapMock,
  MapTypeId: { ROADMAP: '' },
  Marker: MapMock,
  Point: MapMock,
  Size: MapMock,
  places: { Autocomplete: MapMock }
}
