export function getTextContents(els){

  return els.map(singleElement => singleElement.textContent)
}