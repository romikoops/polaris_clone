#!groovy

prettyBuild()

pipeline {
  options {
    podTemplate(inheritFrom: 'default')
    preserveStashes()
    skipDefaultCheckout()
    timeout(60)
  }

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
          [ name: 'elasticsearch', image: 'docker.elastic.co/elasticsearch/elasticsearch:7.1.1',
            requests: [ memory: '1500Mi', cpu: '250m' ],
            env: [ [ name: "discovery.type", value: "single-node" ] ]
          ]
        ]
      )
    }
  }

  stages {
    stage("Test") {
      stages {
        stage("Checkout") {
          steps {
            checkpoint(10)

            defaultCheckout()

            stash(name: "backend", excludes: "client/**/*,qa/**/*")
            stash(name: "frontend", includes: "client/**/*")
          }
        }

        stage("Prepare") {
          parallel {
            stage("Ruby") {
              steps {
                container("ruby") { appPrepare() }
              }
            }

            stage("NPM") {
              steps {
                container("node") {
                  withCache(["client/node_modules=client/package-lock.json"]) {
                    dir("client") {
                      sh(label: "NPM Install", script: "npm install --no-progress")
                    }
                  }
                }
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

            stage("Client") {
              steps {
                container("node") {
                  dir("client") {
                    sh(label: "Run Tests", script: "npm run test:ci")
                  }
                }
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
                dir: '.',
                image: "polaris",
                memory: 1500,
                stash: 'backend',
                pre_script: "scripts/docker-prepare.sh"
              )
            }
          }
        }

        stage("Dipper") {
          steps {
            checkpoint(30) {
              dockerBuild(
                dir: "client/",
                image: "dipper",
                memory: 3000,
                args: [ RELEASE: env.GIT_COMMIT ],
                stash: "frontend",
                artifacts: [source: "/usr/share/nginx/html", destination: "client/dist"]
              )

              s3Upload(
                bucket: env.DIPPER_BUCKET,
                workingDir: "client/dist",
                includePathPattern: "**",
                excludePathPattern: "index.html,config*.js",
                metadatas: ["Revision:${env.GIT_COMMIT}", "Jenkins-Build:${env.BUILD_URL}"],
                verbose: true
              )
            }
          }
        }
      }
    }

    stage("Sentry") {
      when { branch "master" }

      steps {
        checkpoint(40) {
          sentryRelease(projects: ["api", "dipper"])
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
      withCache(['vendor/ruby=Gemfile.lock']) {
        sh(label: "Bundle Install", script: """
          ls Gemfile engines/*/Gemfile \
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
    sh(label: 'Test', script: "scripts/ci-test ${name}")
  }
}
