export const ALIGN_CENTER = 'layout-align-center-center'
export const ALIGN_CENTER_START = 'layout-align-center-start'
export const ALIGN_START_CENTER = 'layout-align-start-center'
export const ALIGN_START = 'layout-align-start-start'
export const ALIGN_BETWEEN_CENTER = 'layout-align-space-between-center'
export const ALIGN_BETWEEN_START = 'layout-align-space-between-start'
export const ALIGN_END = 'layout-align-end-end'
export const ALIGN_END_CENTER = 'layout-align-end-center'
export const ALIGN_AROUND_STRETCH = 'layout-align-space-around-stretch'
export const ALIGN_AROUND_CENTER = 'layout-align-space-around-center'
export const ALIGN_SPACE_BETWEEN = 'layout-align-space-between'
export const ALIGN_START_START = 'layout-align-start-start'

export const ROW = (mode) => {
  if (mode === undefined) {
    return 'flex layout-row'
  } else if (mode === 'CONTENT') {
    return 'content-width layout-row'
  } else if (mode === 'NONE') {
    return 'flex-none layout-row'
  }

  return `flex-${mode} layout-row`
}

export const WRAP_ROW = (mode) => {
  if (mode === undefined) {
    return 'layout-row layout-wrap'
  } else if (mode === 'NONE') {
    return 'flex-none layout-row layout-wrap'
  }

  return `flex-${mode} layout-row layout-wrap`
}

export const COLUMN = mode => `flex-${mode} layout-column`

export const trim = x => x.split('\n').map(y => y.trim()).join(' ').trim()
