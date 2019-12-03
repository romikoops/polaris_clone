#!groovy

def reviewApp

if (env.CHANGE_ID) {
  def project = currentBuild.rawBuild.project
  project.displayName = "PR-${env.CHANGE_ID} – ${env.CHANGE_TITLE}"
}

pipeline {
  agent none

  options {
    ansiColor('xterm')
    buildDiscarder(logRotator(daysToKeepStr: '7', numToKeepStr: '10'))
    podTemplate(inheritFrom: 'default')
    skipDefaultCheckout()
    timeout(120)
    timestamps()

    retry(2)
    preserveStashes()
  }

  stages {
    stage('Test') {
      failFast true

      parallel {
        stage('App') {
          agent {
            kubernetes {
              yaml podSpec(
                containers: [
                  [
                    name: 'ruby', image: 'itsmycargo/builder:ruby-2.6', interactive: true, requests: [ memory: '500Mi', cpu: '500m' ],
                    env: [ [ name: 'DATABASE_URL', value: 'postgis://postgres:@localhost/imcr_test' ] ]
                  ],
                  [ name: 'postgis', image: 'mdillon/postgis', requests: [ memory: '500Mi', cpu: '250m' ] ]
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
                    requests: [ memory: '1500Mi', cpu: '500m' ],
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
