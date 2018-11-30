export default function getCookie (key) {
  const [keyValuePair] = document.cookie.split('; ').filter(x => x.startsWith(`${key}=`))

  if (!keyValuePair) return undefined

  return keyValuePair.split('=')[1]
}
