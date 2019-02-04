import { CONTAINER_DESCRIPTIONS, CONTAINER_TARE_WEIGHTS } from '../constants'

function buildGetSizeClassOptionsFn () {
  return () => (
    Object.entries(CONTAINER_DESCRIPTIONS).reduce((options, [value, label]) => (
      value === 'lcl' ? options : [...options, { value, label }]
    ), [])
  )
}
export const getSizeClassOptions = buildGetSizeClassOptionsFn()

export function getTareWeight (container) {
  return CONTAINER_TARE_WEIGHTS[container.sizeClass]
}
