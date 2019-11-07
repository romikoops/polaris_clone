
function isFalssy (input) {
  return !input || (Object.keys(input).length === 0 && input.constructor === Object)
}

export function Base64encode (input) {
  if (isFalssy(input)) {
    return null
  }

  return window.btoa(unescape(encodeURIComponent(input)))
}

export function Base64decode (input) {
  if (isFalssy(input)) {
    return null
  }

  return decodeURIComponent(escape(window.atob(input)))
}
