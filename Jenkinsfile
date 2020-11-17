#!groovy

defaultBuild()

pipeline {
  options {
    lock(env.BRANCH_NAME)
    podTemplate(inheritFrom: "default")
    skipDefaultCheckout()
  }

  agent none

  stages {
    stage("Checkout") {
      options { timeout(5) }
      agent { kubernetes true }

      steps {
        checkout(scm)
        stash(name: "source")
      }
    }

    stage("Test") {
      parallel {
        stage("Wolfhound") {
          options { timeout(15) }
          steps { wolfhound(stash: "source") }
        }

        stage("Gems") {
          options { timeout(15) }
          environment {
            LC_ALL = "C.UTF-8"
            BUNDLE_PATH = "vendor/ruby"
          }

          agent {
            kubernetes {
              defaultContainer "ruby"
              yaml podSpec(
                containers: [
                  [
                    name: "ruby", image: "ruby:2.6", interactive: true,
                    requests: [ memory: "200Mi", cpu: "250m" ]
                  ]
                ]
              )
            }
          }

          steps {
            unstash(name: "source")

            dir("gems/money_cache") {
              withCache(["vendor/ruby=gems/money_cache/money_cache.gemspec"]) {
                sh("bundle check || bundle install")
              }

              sh("bundle exec rspec")
            }
          }

          post {
            always {
              junit(allowEmptyResults: true, testResults: "**/junit.xml")
              captureCoverage()
            }
          }
        }

        stage("App") {
          options { timeout(45) }
          environment {
            LC_ALL = "C.UTF-8"
            BUNDLE_PATH = "vendor/ruby"
            RAILS_ENV = "test"
          }

          agent {
            kubernetes {
              defaultContainer "ruby"
              yaml podSpec(
                containers: [
                  [
                    name: "ruby", image: "itsmycargo/builder:ruby-2.6", interactive: true,
                    requests: [ memory: "1000Mi", cpu: "2000m" ],
                    env: [
                      [ name: "DATABASE_URL", value: "postgis://postgres:@localhost/polaris_test" ],
                      [ name: "ELASTICSEARCH_URL", value: "http://localhost:9200"]
                    ]
                  ],
                  [ name: "postgis", image: "postgis/postgis:12-2.5-alpine",
                    requests: [ memory: "256Mi", cpu: "250m" ],
                    env: [[name: "POSTGRES_HOST_AUTH_METHOD", value: "trust"]]
                  ],
                  [ name: "redis", image: "redis",
                    requests: [ memory: "25Mi", cpu: "100m" ]
                  ],
                  [ name: "elasticsearch", image: "amazon/opendistro-for-elasticsearch:1.8.0",
                    requests: [ memory: "1024Mi", cpu: "250m" ],
                    env: [
                      [ name: "ES_JAVA_OPTS", value: "-Xms512m -Xmx512m"],
                      [ name: "discovery.type", value: "single-node" ],
                      [ name: "opendistro_security.disabled", value: "true"],
                    ]
                  ]
                ]
              )
            }
          }

          steps {
            unstash(name: "source")
            withCache(["vendor/ruby=Gemfile.lock"]) {
              sh(label: "Bundle Install", script: "bundle check || bundle install")
            }

            sh(label: "Install Postgres 12 Client", script: """
                  apt-get install curl ca-certificates gnupg \
                  && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
                  && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
                  && apt-get update \
                  && apt install -y postgresql-client-12
            """)
            sh(label: "Test Database", script: "bin/rails db:test:prepare && bin/rails db:migrate")

            sh("bundle exec rspec")

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
          coverDiff()
        }
      }
    }

    stage("Build") {
      options { timeout(25) }
      when {
        anyOf {
          branch "master"
          changeRequest()
        }
      }

      steps { buildDocker("polaris") }
    }

    stage("Sentry") {
      options { timeout(5) }
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
