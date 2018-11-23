export const dimensionToPx = (data) => {
  // This helper converts strings in px, vw, and vh
  // to and integer pixel value.
  //
  // Argument is an object with the following properties:
  //
  //   1. data.value (string)
  //      This is the value to be converted
  //
  //   2. data.windowHeight (integer, optional)
  //      The basis for WindowHeight conversion
  //
  //   3. data.windowWdith  (integer, optional)
  //      The basis for WindowWidth conversion
  //
  // Examples:
  //      dimensionToPx({value: 90px})                    //=> 100
  //
  //      dimensionToPx({value: 90px, windowHeight: 200}) //=> 90
  //
  //      dimensionToPx({value: 90vh, windowHeight: 200}) //=> 180

  if (!data || !data.value) return undefined
  let returnValue

  returnValue = data.value.replace('px', '')
  if (!Number.isNaN(+returnValue)) return +returnValue

  returnValue = data.value.replace('vw', '')
  if (data.windowWidth && !Number.isNaN(+returnValue)) {
    returnValue *= data.windowWidth / 100
    return returnValue
  }
  returnValue = data.value.replace('vh', '')
  if (data.windowHeight && !Number.isNaN(+returnValue)) {
    returnValue *= data.windowHeight / 100
    return returnValue
  }
  return -1
}

export default dimensionToPx
