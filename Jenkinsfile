#!groovy

defaultBuild()

pipeline {
  options {
    lock("${jobName()}/${env.BRANCH_NAME}")
    skipDefaultCheckout()
    timeout(90)
  }

  agent none

  stages {
    stage("Checkout") {
      agent { kubernetes true }

      steps {
        checkout(scm)
        stash(name: "source")
      }
    }

    stage("Test") {
      parallel {
        stage("Wolfhound") {
          steps { wolfhound(stash: "source") }
        }

        stage("Gems") {
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
                    name: "ruby", image: "ruby:2.6", command: ["cat"], tty: true,
                    requests: [ memory: "200Mi", cpu: "250m" ]
                  ]
                ]
              )
            }
          }

          steps {
            unstash(name: "source")

            dir("gems/money_cache") {
              withCache(dir: "vendor/ruby", key: "gems/money_cache/money_cache.gemspec") {
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
          agent {
            kubernetes {
              defaultContainer "ruby"
              inheritFrom "default elasticsearch postgis redis"
              yaml podSpec(
                containers: [
                  [
                    name: "ruby", image: "itsmycargo/builder:ruby-2.6", command: ["cat"], tty: true,
                    requests: [ memory: "1Gi", cpu: "1000m" ],
                    env: [
                      [name: "DATABASE_URL", value: "postgis://postgres:@localhost/polaris_test"],
                      [name: "ELASTICSEARCH_URL", value: "http://localhost:9200"],
                    ]
                  ]
                ]
              )
            }
          }

          steps {
            unstash(name: "source")

            withEnv(["LC_ALL=C.UTF-8", "BUNDLE_PATH=vendor/ruby", "RAILS_ENV=test"]) {
              sh(label: "Install Postgres 12 Client", script: """
                    apt-get install curl ca-certificates gnupg \
                    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
                    && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
                    && apt-get update \
                    && apt install -y postgresql-client-12
              """)

              withCache(dir: "vendor/ruby", key: "Gemfile.lock") {
                sh("bundle check || bundle install")
              }

              sh("bin/rails db:test:prepare && bin/rails db:migrate")

              sh("bundle exec rspec --exclude-pattern '{gems,vendor}/**/*_spec.rb' .")
            }
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
          reportCoverage(stash: "source")
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

      steps { buildDocker("polaris", stash: "source") }
    }

    stage("Sentry") {
      when { branch "master" }

      steps { sentryRelease(project: "polaris", repository: "itsmycargo/imc-react-api") }
    }
  }

  post {
    always {
      jiraBuildInfo()
      slackNotify()
    }
  }
}
