export function isDocker () {
  return process.env.E2E_DOCKER === 'true'
}
