export default function interpolate (message, props) {
  let updatedMessage = message

  Object.keys(props).forEach((key) => {
    updatedMessage = updatedMessage.replace(`{${key}}`, props[key])
  })

  return updatedMessage
}
