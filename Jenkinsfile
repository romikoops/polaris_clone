#!groovy

withPipeline(timeout: 120) {
  inPod(
    containers: [
      containerTemplate(name: 'api', image: 'ruby:2.5', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '1000m', resourceLimitCpu: '1000m',
        resourceRequestMemory: '1500Mi', resourceLimitMemory: '1500Mi',
        envVars: [
          envVar(key: 'POSTGRES_DB', value: 'imcr_test'),
          envVar(key: 'DATABASE_URL', value: 'postgis://postgres:@localhost/imcr_test')
        ]
      ),
      containerTemplate(name: 'client', image: 'node:lts-slim', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '1000m', resourceLimitCpu: '1000m',
        resourceRequestMemory: '1500Mi', resourceLimitMemory: '1500Mi',
      ),
      containerTemplate(name: 'postgis', image: 'mdillon/postgis',
        resourceRequestCpu: '250m', resourceLimitCpu: '250m',
        resourceRequestMemory: '500Mi', resourceLimitMemory: '500Mi',
      ),
      containerTemplate(name: 'elasticsearch', image: 'docker.elastic.co/elasticsearch/elasticsearch:6.7.2',
        resourceRequestCpu: '250m', resourceLimitCpu: '250m',
        resourceRequestMemory: '1500Mi', resourceLimitMemory: '1500Mi',
      )
    ]
  ) { label ->
    withNode(label) {
      stage('Checkout') { checkoutScm() }

      stage('Prepare') {
        milestone()

        def jobs = [:]

        jobs['api'] = {
          container('api') {
            timeout(15) {
              withEnv(["BUNDLE_GITHUB__COM=pierbot:${env.GITHUB_TOKEN}", "LC_ALL=C.UTF-8", "BUNDLE_PATH=${env.WORKSPACE}/vendor"]) {
                sh(label: 'Install Dependencies', script: """
                  apt-get update && apt-get install -y \
                    apt-transport-https \
                    automake \
                    build-essential \
                    cmake \
                    git \
                    libgeos-dev \
                    libpq-dev \
                    locales \
                    tzdata

                  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales && \
                      locale-gen C.UTF-8 && \
                      /usr/sbin/update-locale LANG=C.UTF-8

                  curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
                    && echo "deb https://deb.nodesource.com/node_10.x stretch main" | tee /etc/apt/sources.list.d/nodesource.list \
                    && apt-get update && apt-get install -y \
                      nodejs

                  npm install -g 'mjml@4.3.1'
                """)

                withCache(['vendor/ruby=Gemfile.lock']) {
                  sh(label: 'Install Gems', script: 'scripts/test --prepare --no-test')
                }
              }
            }
          }
        }

        jobs['client'] = {
          container('client') {
            timeout(15) {
              sh(label: 'Install Dependencies', script: """
                apt-get update && apt-get install -y \
                  build-essential \
                  gifsicle \
                  libgl1-mesa-glx \
                  libjpeg62-turbo-dev \
                  liblcms2-dev \
                  libpng-dev \
                  libwebp-dev \
                  libxi6 \
                  optipng \
                  pngquant
              """)

              withCache(['client/node_modules=client/package-lock.json']) {
                dir('client') {
                  sh(label: 'NPM Install', script: "npm install --no-progress")
                }
              }
            }
          }
        }

        parallel(jobs)
      }

      def error = null

      stage('Test') {
        milestone()
        try {
          parallel(
            api: {
              container('api') {
                retry(2) {
                  withEnv(["BUNDLE_GITHUB__COM=pierbot:${env.GITHUB_TOKEN}"]) {
                    try {
                      sh(label: 'Test', script: "scripts/test --no-prepare --test")
                    } catch (err) {
                      throw err
                    } finally {
                      junit allowEmptyResults: true, testResults: '**/rspec.xml'
                      publishCoverage adapters: [istanbulCoberturaAdapter('**/coverage.xml')]
                    }
                  }
                }
              }
            },

            client: {
              container('client') {
                retry(2) {
                  try {
                    dir('client') { sh(label: 'Run Tests', script: 'npm run test:ci') }
                  } catch (err) {
                    throw err
                  } finally {
                    junit allowEmptyResults: true, testResults: '**/junit.xml'
                    publishCoverage adapters: [istanbulCoberturaAdapter('**/cobertura-coverage.xml')]
                  }
                }
              }
            },

            analyse: { container('api') { codestyle.analyse(eslint: 'client', rubocop: true) } }
          )
        } catch (err) {
          error = err
        }

        if (env.CHANGE_ID) {
          try {
            parallel(
              danger: { container('api') { withEnv(["LC_ALL=C.UTF-8", "BUNDLE_PATH=${env.WORKSPACE}/vendor"]) { codestyle.danger() } } },
              pronto: { container('api') { withEnv(["LC_ALL=C.UTF-8", "BUNDLE_PATH=${env.WORKSPACE}/vendor"]) { codestyle.pronto() } } }
            )
          } catch (err) {
            // error = err
          }
        }
      }

      if (error) {
        currentBuild.result = 'FAILURE'
        throw error
      }
    }
  }

  if (env.CHANGE_ID) {
    stage('Prepare Deploy') {
      lock(label: "${env.GIT_BRANCH}", inversePrecedence: true) {
        inPod { label ->
          withNode(label) {
            milestone()

            checkoutScm()

            parallel(
              'database': {
                build(
                  job: "Tasks/Production/${jobName()}/dbreset",
                  parameters: [string(name: 'database', value: env.CI_COMMIT_REF_SLUG)]
                )
                },
              'images': {
                googleCloudBuild(
                  substitutions: [
                    COMMIT_SHA: env.GIT_COMMIT,
                    _REPOSITORY: jobName(),
                    _SENTRY_AUTH_TOKEN: '099b9abd2844497db3dace7307576c12fadc7d47bd68416584cdb4b90709de95'
                  ]
                )
              }
            )
          }
        }
      }

      stage('Review') {
        milestone()

        env.REVIEW_NAME = env.CI_COMMIT_REF_SLUG

        inPod { label ->
          withNode(label) {
            githubDeploy(environment: env.REVIEW_NAME, url: "https://${env.REVIEW_NAME}.itsmycargo.tech") {
              deployReview(env.REVIEW_NAME)
            }
          }
        }
      }

      stage('QA') {
        milestone()

        build(
          job: 'Voyage/imc-react-api',
          parameters: [
            string(name: 'APP_NAME', value: 'imc-app'),
            string(name: 'ENVIRONMENT', value: 'review'),
            string(name: 'NAMESPACE', value: 'review'),
            string(name: 'RELEASE', value: env.REVIEW_NAME),
            string(name: 'REPOSITORY', value: jobBaseName()),
            string(name: 'REVISION', value: env.GIT_COMMIT),
          ],
          wait: false)
      }
    }
  }
}

void deployReview(String reviewName) {
  inPod(
    containers: [
      containerTemplate(name: 'deploy', image: 'eu.gcr.io/itsmycargo-main/deploy:latest', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '100m', resourceLimitCpu: '100m',
        resourceRequestMemory: '100Mi', resourceLimitMemory: '100Mi'
      )
    ]
  ) { label ->
    withNode("${label}") {
      checkoutScm()

      container('deploy') {
        sh(label: 'Destory failed deployment',
          script: """
            if [[ -n "\$(helm ls --failed -q "^${reviewName}\$")" ]]; then
              helm delete --purge "${reviewName}" || true
            fi
          """
        )

        sh(label: 'Helm Deploy',
          script: """
            helm upgrade --install \
              --wait \
              --timeout 600 \
              --set meta.changeId="${env.CHANGE_ID}" \
              --set meta.changeRepo="${jobName()}" \
              --set backend.image.tag="${env.GIT_COMMIT}" \
              --set frontend.image.tag="${env.GIT_COMMIT}" \
              --set ingress.domain="itsmycargo.tech" \
              --set postgres.database=${reviewName} \
              --set vault.endpoint="${env.VAULT_ADDR}" \
              --set vault.roleName="${jobName()}" \
              --namespace=review \
              "${reviewName}" \
              chart/
          """
        )
      }
    }
  }
}
