export const gradientGenerator = (colour1, colour2) => {
  if ((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1) {
    return { background: `-o-linear-gradient(-90deg, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Chrome') !== -1) {
    return { background: `-webkit-linear-gradient(-90deg, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Safari') !== -1) {
    return { background: `-webkit-linear-gradient(-90deg, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    return { background: `-moz-linear-gradient(-90deg, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true) {
    return { background: `linear-gradient(to -90deg, ${colour1} 0%, ${colour2} 100%)` }
  }

  return { background: `-webkit-linear-gradient(-90deg, ${colour1},${colour2})` }
}

export const gradientCSSGenerator = (colour1, colour2) => {
  if ((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1) {
    return `-o-linear-gradient(-90deg, ${colour1},${colour2})`
  } else if (navigator.userAgent.indexOf('Chrome') !== -1) {
    return `-webkit-linear-gradient(-90deg, ${colour1},${colour2})`
  } else if (navigator.userAgent.indexOf('Safari') !== -1) {
    return `-webkit-linear-gradient(-90deg, ${colour1},${colour2})`
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    return `-moz-linear-gradient(-90deg, ${colour1},${colour2})`
  } else if (navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true) {
    return `linear-gradient(to -90deg, ${colour1} 0%, ${colour2} 100%)`
  }

  return `-webkit-linear-gradient(-90deg, ${colour1},${colour2})`
}

export const gradientTextGenerator = (colour1, colour2) => {
  if ((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1) {
    return { background: `-o-linear-gradient(-90deg, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Chrome') !== -1) {
    return { background: `-webkit-linear-gradient(-90deg, ${colour1} 0%,${colour2} 100%)` }
  } else if (navigator.userAgent.indexOf('Safari') !== -1) {
    return { background: `-webkit-linear-gradient(-90deg, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    return { background: `-moz-linear-gradient(-90deg, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true) {
    return { color: colour1 }
  }

  return { background: `-webkit-linear-gradient(-90deg, ${colour1},${colour2})` }
}

export const gradientBorderGenerator = (colour1, colour2, direction = '-90deg') => {
  if ((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1) {
    return { backgroundImage: `-o-linear-gradient(${direction}, ${colour1}, ${colour2})` }
  } else if (navigator.userAgent.indexOf('Chrome') !== -1) {
    return { backgroundImage: `-webkit-linear-gradient(${direction}, ${colour1}, ${colour2})` }
  } else if (navigator.userAgent.indexOf('Safari') !== -1) {
    return { backgroundImage: `-webkit-linear-gradient(${direction}, ${colour1}, ${colour2})` }
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    return { backgroundImage: `-moz-linear-gradient(${direction}, farthest-corner, ${colour1} 0%, ${colour2} 50%)` }
  } else if (navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true) {
    return { color: 'black' }
  }

  return { backgroundImage: `-webkit-linear-gradient(${direction}, ${colour1}, ${colour2})` }
}
