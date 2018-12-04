export default function removeTabIndex (map, gMaps) {
  map.addListener('idle', () => {
    setTimeout(() => {
      Array.from(document.querySelectorAll('#map div')).forEach((div) => {
        if (div.attributes.tabindex) div.setAttribute('tabindex', '-1')
      })
      Array.from(document.querySelectorAll('#map a, #map iframe, #map img')).forEach((elem) => {
        elem.setAttribute('tabindex', '-1')
      })

      gMaps.event.clearListeners('idle')
    }, 2000)
  })
}
