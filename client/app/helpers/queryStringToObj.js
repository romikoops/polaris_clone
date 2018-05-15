export default function queryStringToObj (queryString) {
  const decodedQueryString = decodeURI(queryString).replace(/%40/g, '@')

  if (decodedQueryString === '') return {}

  return JSON.parse(`{"${decodedQueryString.replace(/&/g, '","').replace(/=/g, '":"')}"}`)
}
