export default function hexToRGB (hex, alpha) {
  if (!(/^#([A-Fa-f0-9]{3}){1,2}$/.test(hex) && [4, 7].includes(hex.length))) {
    throw new Error('Bad Hex')
  }
  let r
  let g
  let b
  if (hex.length === 4) {
    r = parseInt(hex[1] + hex[1], 16)
    g = parseInt(hex[2] + hex[2], 16)
    b = parseInt(hex[3] + hex[3], 16)
  } else {
    r = parseInt(hex.slice(1, 3), 16)
    g = parseInt(hex.slice(3, 5), 16)
    b = parseInt(hex.slice(5, 7), 16)
  }

  return alpha ? `rgba(${r}, ${g}, ${b}, ${alpha})` : `rgb(${r}, ${g}, ${b})`
}
