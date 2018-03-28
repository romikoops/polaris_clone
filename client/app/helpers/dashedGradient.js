export default function dashedGradient (color1, color2) {
  return `linear-gradient(to right, transparent 70%, white 30%), ` +
    `linear-gradient(to right, ${color1}, ${color2})`
}
