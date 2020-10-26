#!groovy

defaultBuild()

pipeline {
  options {
    disableConcurrentBuilds()
    podTemplate(inheritFrom: "default")
    preserveStashes()
    skipDefaultCheckout()
    timeout(60)
  }

  agent none

  stages {
    stage("Test") {
      parallel {
        stage("Wolfhound") {
          steps { wolfhound(required: ["rubocop"]) }
        }

        stage("App") {
          agent {
            kubernetes {
              defaultContainer "ruby"
              yaml podSpec(
                containers: [
                  [
                    name: "ruby", image: "itsmycargo/builder:ruby-2.6", interactive: true,
                    requests: [ memory: "1500Mi", cpu: "1000m" ],
                    env: [
                      [ name: "DATABASE_URL", value: "postgis://postgres:@localhost/polaris_test" ],
                      [ name: "ELASTICSEARCH_URL", value: "localhost:9200"]
                    ]
                  ],
                  [ name: "postgis", image: "postgis/postgis:12-2.5-alpine",
                    requests: [ memory: "500Mi", cpu: "250m" ],
                    env: [[name: "POSTGRES_HOST_AUTH_METHOD", value: "trust"]]
                  ],
                  [ name: "redis", image: "redis",
                    requests: [ memory: "50Mi", cpu: "100m" ]
                  ]
                ]
              )
            }
          }

          steps {
            checkout(scm)
            appPrepare()
            appRunner("app")
          }

          post {
            always {
              junit(allowEmptyResults: true, testResults: "**/junit.xml")
              captureCoverage()
            }
          }
        }

        stage("Engine") {
          agent {
            kubernetes {
              defaultContainer "ruby"
              yaml podSpec(
                containers: [
                  [
                    name: "ruby", image: "itsmycargo/builder:ruby-2.6", interactive: true,
                    requests: [ memory: "1500Mi", cpu: "1000m" ],
                    env: [
                      [ name: "DATABASE_URL", value: "postgis://postgres:@localhost/polaris_test" ],
                      [ name: "ELASTICSEARCH_URL", value: "http://localhost:9200"]
                    ]
                  ],
                  [ name: "postgis", image: "postgis/postgis:12-2.5-alpine",
                    requests: [ memory: "500Mi", cpu: "250m" ],
                    env: [[name: "POSTGRES_HOST_AUTH_METHOD", value: "trust"]]
                  ],
                  [ name: "redis", image: "redis",
                    requests: [ memory: "50Mi", cpu: "100m" ]
                  ],
                  [ name: "elasticsearch", image: "amazon/opendistro-for-elasticsearch:1.8.0",
                    requests: [ memory: "1500Mi", cpu: "250m" ],
                    env: [
                      [ name: "discovery.type", value: "single-node" ],
                      [ name: "opendistro_security.disabled", value: "true"]
                    ]
                  ]
                ]
              )
            }
          }

          steps {
            checkout(scm)
            appPrepare()
            appRunner("engines")
          }

          post {
            always {
              junit(allowEmptyResults: true, testResults: "**/junit.xml")
              captureCoverage()
            }
          }
        }
      }

      post {
        always {
          reportCoverage()
          coverDiff()
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

      steps { buildDocker("polaris") }
    }

    stage("Sentry") {
      when { branch "master" }

      steps { sentryRelease(projects: ["polaris"]) }
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
          sh(label: "Install Postgres 12 Client", script: """
                apt-get install curl ca-certificates gnupg \
                && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
                && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
                && apt-get update \
                && apt install -y postgresql-client-12
          """)
          sh(label: "Test Database", script: "bin/rails db:test:prepare && bin/rails db:migrate")
        }
      }
    }
  }
}

void appRunner(String name) {
  withEnv(["LC_ALL=C.UTF-8", "BUNDLE_PATH=${env.WORKSPACE}/vendor/ruby"]) {
    sh(label: "Test", script: "scripts/ci-test ${name}")
  }
}
