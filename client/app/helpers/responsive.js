const GT_BREAKPOINTS = {
  gtXs: '(min-width: 600px)',
  gtSm: '(min-width: 960px)',
  gtMd: '(min-width: 1280px)',
  gtLg: '(min-width: 1920px)'
}

const BREAKPOINTS = {
  xs: '(max-width: 599px)',
  sm: '(min-width: 600px) and (max-width: 959px)',
  md: '(min-width: 960px) and (max-width: 1279px)',
  lg: '(min-width: 1280px) and (max-width: 1919px)',
  xl: '(min-width: 1920px)'
}

function getMatchingBreakpoint () {
  // returns a string with the breakpoint that matches the current window's viewport width (ex: 'sm')

  return getMatchingBreakpoints[0]
}

function getMatchingBreakpoints (options = {}) {
  // returns an array of breakpoints that match the current window's viewport width
  // available options:
  //   default - excludes the 'gt' breakpoint matches (ex: ['xs'])
  //   withGt  - adds the 'gt' breakpoint matches to the return (ex: ['sm', 'gtXs'])
  //   onlyGt  - only returns the 'gt' breakpoint matches (ex: ['gtXs', 'gtSm'])

  let breakpoints = []

  if (!options.onlyGt) breakpoints = breakpoints.concat(Object.entries(BREAKPOINTS))
  if (options.withGt || options.onlyGt) breakpoints = breakpoints.concat(Object.entries(GT_BREAKPOINTS))

  return breakpoints
    .filter(([breakpointKey, media]) => window.matchMedia(media).matches)
    .map(([breakpointKey, media]) => breakpointKey)
}

function matchBreakpoint (obj) {
  let result = obj[getMatchingBreakpoint()]
  if (result) return result

  getMatchingBreakpoints({ onlyGt: true }).reverse().some(breakpoint => (result = obj[breakpoint]))

  return result || obj.default || 6
}

const responsive = {
  getMatchingBreakpoint,
  getMatchingBreakpoints,
  matchBreakpoint,
  breakpoints: [600, 960, 1280, 1920]
}

export default responsive
