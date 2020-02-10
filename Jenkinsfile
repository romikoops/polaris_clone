#!groovy

prettyBuild()

pipeline {
  agent none

  options {
    ansiColor('xterm')
    buildDiscarder(logRotator(daysToKeepStr: '7', numToKeepStr: '10'))
    podTemplate(inheritFrom: 'default')
    preserveStashes()
    skipDefaultCheckout()
    timeout(45)
  }

  stages {
    stage('Test') {
      parallel {
        stage('App') {
          agent {
            kubernetes {
              yaml podSpec(
                containers: [
                  [
                    name: 'ruby', image: 'itsmycargo/builder:ruby-2.6', interactive: true,
                    requests: [ memory: '1500Mi', cpu: '1000m' ],
                    env: [ [ name: 'DATABASE_URL', value: 'postgis://postgres:@localhost/imcr_test' ] ]
                  ],
                  [ name: 'postgis', image: 'mdillon/postgis', requests: [ memory: '500Mi', cpu: '500m' ] ]
                ]
              )
            }
          }

          stages {
            stage('Checkout') {
              steps {
                defaultCheckout()

                stash(name: 'backend', excludes: 'client/**/*,qa/**/*')
              }
            }

            stage('Prepare') {
              steps {
                container('ruby') { appPrepare() }
              }
            }

            stage('RSpec') {
              steps {
                defaultCheckout()
                container('ruby') { appRunner('app') }
              }

              post {
                always {
                  junit allowEmptyResults: true, testResults: '**/junit.xml'
                  stash(name: 'app-lcov', includes: 'coverage/lcov/*.lcov')
                }

                success {
                  publishCoverage adapters: [
                    istanbulCoberturaAdapter(mergeToOneReport: true, path: 'coverage/coverage.xml')
                  ]
                }
              }
            }
          }
        }

        stage('Engines') {
          agent {
            kubernetes {
              yaml podSpec(
                containers: [
                  [
                    name: 'ruby', image: 'itsmycargo/builder:ruby-2.6', interactive: true,
                    requests: [ memory: '1500Mi', cpu: '1000m' ],
                    env: [
                      [ name: 'DATABASE_URL', value: 'postgis://postgres:@localhost/imcr_test' ],
                      [ name: 'ELASTICSEARCH_URL', value: 'localhost:9200']
                    ]
                  ],
                  [ name: 'postgis', image: 'mdillon/postgis',
                    requests: [ memory: '500Mi', cpu: '250m' ]
                  ],
                  [ name: 'elasticsearch', image: 'docker.elastic.co/elasticsearch/elasticsearch:7.1.1',
                    requests: [ memory: '1500Mi', cpu: '250m' ],
                    env: [ [ name: "discovery.type", value: "single-node" ] ]
                  ]
                ]
              )
            }
          }

          stages {
            stage('Checkout') {
              steps {
                defaultCheckout()
              }
            }

            stage('Prepare') {
              steps {
                container('ruby') { appPrepare() }
              }
            }

            stage('RSpec') {
              steps {
                container('ruby') { appRunner('engines') }
              }

              post {
                always {
                  junit allowEmptyResults: true, testResults: '**/junit.xml'
                  stash(name: 'engines-lcov', includes: 'coverage/lcov/*.lcov', allowEmpty: true)
                }

                success {
                  publishCoverage adapters: [
                    istanbulCoberturaAdapter(mergeToOneReport: true, path: 'coverage/coverage.xml')
                  ]
                }
              }
            }
          }
        }

        stage('Client') {
          agent {
            kubernetes {
              yaml podSpec(
                containers: [
                  [ name: 'node', image: 'itsmycargo/builder:node-12', command: 'cat', tty: true,
                    requests: [ memory: '3000Mi', cpu: '1000m' ],
                  ]
                ]
              )
            }
          }

          stages {
            stage('Checkout') {
              steps {
                defaultCheckout()

                stash(name: 'frontend', includes: 'client/**/*')
                stash(name: 'qa', includes: 'qa/**/*')
              }
            }

            stage('Prepare') {
              steps {
                container('node') {
                  withCache(['client/node_modules=client/package-lock.json']) {
                    dir('client') {
                      sh(label: 'NPM Install', script: "npm install --no-progress")
                    }
                  }
                }
              }
            }

            stage('Jest') {
              steps {
                container('node') {
                  dir('client') {
                    sh(label: 'Run Tests', script: 'npm run test:ci')
                  }
                }
              }

              post {
                always {
                  junit 'client/**/junit.xml'
                }

                success {
                  publishCoverage adapters: [istanbulCoberturaAdapter(mergeToOneReport: true, path: '**/cobertura-coverage.xml')]
                }
              }
            }
          }
        }

      } // parallel
    } // Test

    stage('Report') {
      when { changeRequest() }

      steps {
        underCover(stashes: ['app-lcov', 'engines-lcov'])
      }
    } // Report

    stage('Build') {
      parallel {
        stage('Backend') {
          steps {
            dockerBuild(
              dir: '.',
              image: "${jobName()}/backend",
              memory: 1500,
              stash: 'backend',
              pre_script: "scripts/docker-prepare.sh"
            )
          }
        }

        stage("Frontend / Docker") {
          stages {
            stage('Build') {
              steps {
                dockerBuild(
                  dir: 'client/',
                  image: "${jobName()}/frontend",
                  memory: 2000,
                  args: [
                    RELEASE: env.GIT_COMMIT,
                    SENTRY_AUTH_TOKEN: "env:SENTRY_AUTH_TOKEN"
                  ],
                  stash: 'frontend'
                )
              }
            }
          }
        }

        stage("Frontend / S3") {
          agent {
            kubernetes {
              yaml podSpec(
                containers: [
                  [ name: 'node', image: 'node:12-slim', command: 'cat', tty: true,
                    requests: [ memory: '3000Mi', cpu: '1000m' ],
                  ]
                ]
              )
            }
          }

          stages {
            stage('Build') {
              steps {
                defaultCheckout()
                container('node') {
                  withCache(['client/node_modules=client/package-lock.json']) {
                    dir('client') {
                      sh(label: 'NPM Install', script: "npm install --no-progress")
                      sh("npm run build")
                    }
                  }
                }
              }
            }

            stage('Deploy') {
              when { branch 'master' }

              steps {
                withSecrets {
                  s3Upload(
                    bucket: env.DIPPER_BUCKET,
                    workingDir: "client/dist",
                    includePathPattern: "**",
                    excludePathPattern: "index.html,config*.js,*.map*",
                    metadatas: ["Revision:${env.GIT_COMMIT}"],
                    verbose: true
                  )
                }
              }
            }
          }
        }
      }
    }
  }

  post {
    always {
      jiraBuildInfo(site: 'itsmycargo.atlassian.net', issues: env.BUILD_ISSUES)
    }
  }
}

void appPrepare() {
  withSecrets {
    withEnv([
      "BUNDLE_BUILD__SASSC=--disable-march-tune-native",
      "BUNDLE_GITHUB__COM=pierbot:${env.GITHUB_TOKEN}",
      "BUNDLE_PATH=${env.WORKSPACE}/vendor/ruby",
      "LC_ALL=C.UTF-8",
    ]) {
      withCache(['vendor/ruby=Gemfile.lock']) {
        sh(label: 'Install Gems', script: "scripts/ci-prepare")
      }
    }
  }
}

void appRunner(String name) {
  withEnv(["BUNDLE_GITHUB__COM=pierbot:${env.GITHUB_TOKEN}", "LC_ALL=C.UTF-8", "BUNDLE_PATH=${env.WORKSPACE}/vendor/ruby"]) {
    sh(label: 'Test', script: "scripts/ci-test ${name}")
  }
}
