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
                    name: 'ruby', image: 'ruby:2.6', interactive: true, requests: [ memory: '500Mi', cpu: '500m' ],
                    env: [ [ name: 'DATABASE_URL', value: 'postgis://postgres:@localhost/imcr_test' ] ]
                  ],
                  [ name: 'postgis', image: 'mdillon/postgis', requests: [ memory: '500Mi', cpu: '250m' ] ]
                ]
              )
            }
          }

          stages {
            stage('Setup') {
              steps {
                defaultCheckout()
                container('ruby') { appSetup() }
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
                    name: 'ruby', image: 'ruby:2.6', interactive: true,
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
            stage('Setup') {
              steps {
                defaultCheckout()
                container('ruby') { appSetup() }
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
                  [ name: 'node', image: 'node:12-slim', command: 'cat', tty: true,
                    requests: [ memory: '1500Mi', cpu: '500m' ],
                  ]
                ]
              )
            }
          }

          stages {
            stage('Setup') {
              steps {
                defaultCheckout()
                container('node') {
                  sh(label: 'Install Dependencies', script: """
                    apt-get update && apt-get install -y build-essential gifsicle libgl1-mesa-glx \
                      libjpeg62-turbo-dev liblcms2-dev libpng-dev libwebp-dev libxi6 optipng \
                      pngquant
                  """)
                }
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

void appSetup() {
  sh(label: 'Install Dependencies', script: """
    apt-get update && apt-get install -y \
      apt-transport-https \
      automake \
      build-essential \
      cmake \
      git \
      libgeos-dev \
      libpq-dev \
      libssl-dev \
      locales \
      tzdata \
      wkhtmltopdf

    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales && \
        locale-gen C.UTF-8 && \
        /usr/sbin/update-locale LANG=C.UTF-8

    curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
      && echo "deb https://deb.nodesource.com/node_12.x stretch main" | tee /etc/apt/sources.list.d/nodesource.list \
      && apt-get update && apt-get install -y \
        nodejs

    npm install -g 'mjml@4.3.1'
  """)
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
