export default function setCookie (key, value) {
  // Set expiry date to one year
  const expires = new Date(Date.now() + 365 * 864e5).toUTCString()

  document.cookie = `${key}=${value}; expires=${expires}; path=/`
}
