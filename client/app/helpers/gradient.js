export const gradientGenerator = (colour1, colour2) => {
  if ((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1) {
    return { background: `-o-linear-gradient(left, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Chrome') !== -1) {
    return { background: `-webkit-linear-gradient(left, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Safari') !== -1) {
    return { background: `-webkit-linear-gradient(left, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    return { background: `-moz-linear-gradient(left, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true) {
    return { background: `linear-gradient(to left, ${colour1} 0%, ${colour2} 100%)` }
  }

  return { background: `-webkit-linear-gradient(left, ${colour1},${colour2})` }
}

export const gradientCSSGenerator = (colour1, colour2) => {
  if ((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1) {
    return `-o-linear-gradient(left, ${colour1},${colour2})`
  } else if (navigator.userAgent.indexOf('Chrome') !== -1) {
    return `-webkit-linear-gradient(left, ${colour1},${colour2})`
  } else if (navigator.userAgent.indexOf('Safari') !== -1) {
    return `-webkit-linear-gradient(left, ${colour1},${colour2})`
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    return `-moz-linear-gradient(left, ${colour1},${colour2})`
  } else if (navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true) {
    return `linear-gradient(to left, ${colour1} 0%, ${colour2} 100%)`
  }

  return `-webkit-linear-gradient(left, ${colour1},${colour2})`
}

export const gradientTextGenerator = (colour1, colour2) => {
  if ((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1) {
    return { background: `-o-linear-gradient(left, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Chrome') !== -1) {
    return { background: `-webkit-linear-gradient(left, ${colour1} 0%,${colour2} 100%)` }
  } else if (navigator.userAgent.indexOf('Safari') !== -1) {
    return { background: `-webkit-linear-gradient(left, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    return { background: `-moz-linear-gradient(left, ${colour1},${colour2})` }
  } else if (navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true) {
    return { color: colour1 }
  }

  return { background: `-webkit-linear-gradient(left, ${colour1},${colour2})` }
}

export const gradientBorderGenerator = (colour1, colour2, gradientSize) => {
  if ((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1) {
    return { backgroundImage: `-webkit-gradient(radial, right top, 10, 90% 0%, ${gradientSize}, from(${colour1}), to(${colour2}))` }
  } else if (navigator.userAgent.indexOf('Chrome') !== -1) {
    return { backgroundImage: `-webkit-gradient(radial, right top, 10, 90% 0%, ${gradientSize}, from(${colour1}), to(${colour2}))` }
  } else if (navigator.userAgent.indexOf('Safari') !== -1) {
    return { backgroundImage: `-webkit-gradient(radial, right top, 10, 90% 0%, ${gradientSize}, from(${colour1}), to(${colour2}))` }
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    return { backgroundImage: `background-image: -moz-radial-gradient(right top, farthest-corner, ${colour1} 0%, ${colour2} 50%)` }
  } else if (navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true) {
    return { color: 'black' }
  }

  return { backgroundImage: `-webkit-gradient(radial, right top, 10, 90% 0%, ${gradientSize}, from(${colour1}), to(${colour2}))` }
}

export const gradientBorderGeneratorBig = (colour1, colour2) => {
  if ((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1) {
    return { backgroundImage: `-webkit-gradient(radial, right top, 10, 90% 0%, 450, from(${colour1}), to(${colour2}))` }
  } else if (navigator.userAgent.indexOf('Chrome') !== -1) {
    return { backgroundImage: `-webkit-gradient(radial, right top, 10, 90% 0%, 450, from(${colour1}), to(${colour2}))` }
  } else if (navigator.userAgent.indexOf('Safari') !== -1) {
    return { backgroundImage: `-webkit-gradient(radial, right top, 10, 90% 0%, 450, from(${colour1}), to(${colour2}))` }
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    return { backgroundImage: `background-image: -moz-radial-gradient(right top, farthest-corner, ${colour1} 0%, ${colour2} 50%)` }
  } else if (navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true) {
    return { color: 'black' }
  }

  return { backgroundImage: `-webkit-gradient(radial, right top, 10, 90% 0%, 450, from(${colour1}), to(${colour2}))` }
}
