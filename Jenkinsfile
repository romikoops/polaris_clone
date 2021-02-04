#!groovy

defaultBuild()

pipeline {
  options {
    lock("${jobName()}/${env.BRANCH_NAME}")
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
          options { timeout(60) }

          agent {
            kubernetes {
              defaultContainer "ruby"
              inheritFrom "default postgis redis elasticsearch"
              yaml """
              kind: Pod
              spec:
                containers:
                - name: ruby
                  image: itsmycargo/builder:ruby-2.6
                  imagePullPolicy: Always
                  command:
                  - cat
                  tty: true
                  resources:
                    requests:
                      cpu: 1000m
                      memory: 1000Mi
                    limits:
                      cpu: 1000m
                      memory: 1000Mi
                  env:
                  - name: DATABASE_URL
                    value: postgis://postgres:@localhost/polaris_test
                  - name: ELASTICSEARCH_URL
                    value: http://localhost:9200
              """
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
      options { timeout(25) }
      when {
        anyOf {
          branch "master"
          changeRequest()
        }
      }

      steps { buildDocker("polaris", stash: "source") }
    }

    stage("Sentry") {
      options { timeout(5) }
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
