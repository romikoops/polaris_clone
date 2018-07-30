const { SimpleConsole } = require('./_modules/simpleConsole')

global.console = new SimpleConsole(process.stdout, process.stderr)

jasmine.DEFAULT_TIMEOUT_INTERVAL = 4 * 60 * 1000
