export default function debounce (func, ms, undebouncedCallback) {
  let timeout

  return (...args) => {
    if (undebouncedCallback) undebouncedCallback(...args)

    const later = () => {
      timeout = null
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, ms)
  }
}
