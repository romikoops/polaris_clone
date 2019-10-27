import { sortBy } from 'lodash'
import {
  CONTAINER_TYPES,
  CONTAINER_TARE_WEIGHTS
} from '../constants'

export function getSizeClassOptions (validKeys) {
  let sizesToRender = CONTAINER_TYPES.filter(x =>
    x.type !== 'lcl' && (!validKeys || validKeys.indexOf(x.type) > -1)
  )

  sizesToRender = sortBy(sizesToRender, 'order')
    .map(x => ({ label: x.label, value: x.type }))

  return sizesToRender
}

export function getTareWeight (container) {
  return CONTAINER_TARE_WEIGHTS[container.sizeClass]
}
