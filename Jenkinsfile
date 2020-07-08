#!groovy

prettyBuild()

pipeline {
  options {
    podTemplate(inheritFrom: 'default')
    preserveStashes()
    skipDefaultCheckout()
    timeout(60)
  }

  agent none

  stages {
    stage("Test") {
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
              [ name: 'node', image: 'itsmycargo/builder:node-12', command: 'cat', tty: true,
                requests: [ memory: '3000Mi', cpu: '1000m' ],
              ],
              [ name: 'postgis', image: 'mdillon/postgis',
                requests: [ memory: '500Mi', cpu: '250m' ]
              ],
              [ name: 'redis', image: 'redis',
                requests: [ memory: '50Mi', cpu: '100m' ]
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
        stage("Checkout") {
          steps {
            checkpoint(10)

            defaultCheckout()

            stash(name: "backend", excludes: "client/**/*,qa/**/*")
            stash(name: "frontend", includes: "client/**/*")
          }
        }

        // stage("Wolfhound") {
        //   steps {
        //     wolfhound(
        //       required: ["eslintnpm", "rubocop"]
        //     )
        //   }
        // }

        stage("Prepare") {
          parallel {
            stage("Ruby") {
              steps {
                container("ruby") { appPrepare() }
              }
            }
          }
        }

        stage("Test") {
          parallel {
            stage("App") {
              steps {
                container("ruby") { appRunner("app") }
              }
            }

            stage("Engines") {
              steps {
                container("ruby") { appRunner("engines") }
              }
            }
          }

          post {
            always {
              junit(allowEmptyResults: true, testResults: '**/junit.xml')

              reportCoverage()
              coverDiff()
            }
          }
        }
      }
    }

    stage("Build") {
      when {
        anyOf {
          branch "master"
          changeRequest()
        }
      }

      stages {
        stage("Polaris") {
          steps {
            checkpoint(20) {
              dockerBuild(
                dir: ".",
                image: "polaris",
                memory: 1500,
                stash: "backend",
                pre_script: "scripts/docker-prepare.sh"
              )
            }
          }
        }
      }
    }

    stage("Deploy") {
      when { branch "master" }

      stages {
        stage("Sentry") {
          steps {
            checkpoint(50) { sentryRelease(projects: ["polaris", "dipper"]) }
          }
        }
      }
    }
  }

  post {
    always {
      jiraBuildInfo()
      slackNotify()
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
      withCache(["vendor/ruby=Gemfile.lock"]) {
        sh(label: "Bundle Install", script: """
            ls Gemfile engines/*/Gemfile lib/money_cache/Gemfile \
            | xargs -P 4 -I {} sh -c "BUNDLE_GEMFILE={} bundle check 1>&2 || echo {}" \
            | xargs -I {} sh -c "BUNDLE_GEMFILE={} bundle install --retry=2 --jobs=2"
        """)

        withEnv(["RAILS_ENV=test"]) {
          sh(label: "Test Database", script: "bin/rails db:test:prepare && bin/rails db:migrate")
        }
      }
    }
  }
}

void appRunner(String name) {
  withEnv(["BUNDLE_GITHUB__COM=pierbot:${env.GITHUB_TOKEN}", "LC_ALL=C.UTF-8", "BUNDLE_PATH=${env.WORKSPACE}/vendor/ruby"]) {
    sh(label: "Test", script: "scripts/ci-test ${name}")
  }
}

