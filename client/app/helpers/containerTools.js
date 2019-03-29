import { CONTAINER_DESCRIPTIONS, CONTAINER_TARE_WEIGHTS } from '../constants'

export function getSizeClassOptions (validKeys) {
  let sizesToRender
  if (validKeys) {
    const limitedContainers = {}
    validKeys.forEach((k) => {
      limitedContainers[k] = CONTAINER_DESCRIPTIONS[k]
    })
    sizesToRender = Object.entries(limitedContainers)
  } else {
    sizesToRender = Object.entries(CONTAINER_DESCRIPTIONS)
  }

  return sizesToRender.reduce((options, [value, label]) => (
    value === 'lcl' ? options : [...options, { value, label }]
  ), [])
}

export function getTareWeight (container) {
  return CONTAINER_TARE_WEIGHTS[container.sizeClass]
}
