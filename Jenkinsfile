#!groovy

wrap.pipeline(timeout: 120) {
  inPod(
    containers: [
      containerTemplate(name: 'api', image: 'ruby:2.5', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '1000m', resourceLimitCpu: '1500m',
        resourceRequestMemory: '1000Mi', resourceLimitMemory: '1500Mi',
        envVars: [
          envVar(key: 'POSTGRES_DB', value: 'imcr_test'),
          envVar(key: 'DATABASE_URL', value: 'postgis://postgres:@localhost/imcr_test')
        ]
      ),
      containerTemplate(name: 'client', image: 'node:10-alpine', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '1000m', resourceLimitCpu: '1200m',
        resourceRequestMemory: '1000Mi', resourceLimitMemory: '1200Mi',
      ),
      containerTemplate(name: 'postgis', image: 'mdillon/postgis',
        resourceRequestCpu: '250m', resourceLimitCpu: '500m',
        resourceRequestMemory: '400Mi', resourceLimitMemory: '500Mi',
      ),
      containerTemplate(name: 'elasticsearch', image: 'docker.elastic.co/elasticsearch/elasticsearch:6.6.1',
        resourceRequestCpu: '250m', resourceLimitCpu: '500m',
        resourceRequestMemory: '1000Mi', resourceLimitMemory: '1500Mi',
      )
    ]
  ) { label ->
    wrap.node(label) {
      stage('Checkout') { checkoutScm() }

      stage('Prepare') {
        milestone()

        def jobs = [:]

        jobs['api'] = {
          container('api') {
            timeout(10) {
              withEnv(["BUNDLE_GITHUB__COM=pierbot:${env.GITHUB_TOKEN}", "LC_ALL=C.UTF-8"]) {
                sh """
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
                """

                sh 'scripts/prepare'
              }
            }
          }
        }

        jobs['client'] = {
          container('client') {
            timeout(10) {
              sh """
                apk add --no-cache --update \
                  autoconf automake bash build-base gifsicle lcms2-dev libjpeg-turbo-utils libpng-dev libtool \
                  libwebp-tools nasm optipng pngquant
              """

              dir('client') {
                sh "npm install --no-progress"
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
                timeout(10) {
                  withEnv(["BUNDLE_GITHUB__COM=pierbot:${env.GITHUB_TOKEN}"]) {
                    try {
                      sh "scripts/test"
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
                timeout(10) {
                  try {
                    dir('client') { sh 'npm run test:ci' }
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
              danger: { container('api') { withEnv(["LC_ALL=C.UTF-8"]) { codestyle.danger() } } },
              pronto: { container('api') { withEnv(["LC_ALL=C.UTF-8"]) { codestyle.pronto() } } }
            )
          } catch (err) {
            error = err
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
    wrap.stage('Prepare Deploy') {
      lock(label: "${env.GIT_BRANCH}", inversePrecedence: true) {
        inPod { label ->
          wrap.node(label) {
            milestone()

            checkoutScm()

            parallel(
              'database': {
                build(
                  job: 'Tasks/Production/review/dbreset',
                  parameters: [string(name: 'database', value: env.CI_COMMIT_REF_SLUG)]
                )
                },
              'images': {
                sh """
                  rm -rf .build
                  mkdir -p .build
                  find . -depth -type f -name '*.gemspec' | cpio -d -v -p .build/
                """
                googleCloudBuild(
                  credentialsId: 'itsmycargo-main',
                  request: file('cloudbuild.yaml'),
                  source: local('.'),
                  substitutions: [
                    BRANCH_NAME: env.BRANCH_NAME,
                    COMMIT_SHA: env.GIT_COMMIT,
                    _PREVIOUS_COMMIT_SHA: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT,
                    _SENTRY_AUTH_TOKEN: '099b9abd2844497db3dace7307576c12fadc7d47bd68416584cdb4b90709de95'
                  ]
                )
              }
            )
          }
        }
      }

      wrap.stage('Review') {
        milestone()

        env.REVIEW_NAME = env.CI_COMMIT_REF_SLUG

        githubDeploy(environment: env.REVIEW_NAME, url: "https://${env.REVIEW_NAME}.itsmycargo.tech") {
          deployReview(env.REVIEW_NAME)
        }
      }

      stage('QA') {
        milestone()

        parallel(knapsack(2, 'Cucumber') { cucumberTests() })
      }

      milestone()
    }
  }
}

void deployReview(String reviewName) {
  inPod(
    containers: [
      containerTemplate(name: 'deploy', image: 'eu.gcr.io/itsmycargo-main/deploy:latest', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '100m',
        resourceLimitCpu: '120m',
        resourceRequestMemory: '200Mi',
        resourceLimitMemory: '300Mi',
        envVars: [
          secretEnvVar(key: 'REVIEW_MASTER_KEY', secretName: 'jenkins-worker', secretKey: 'app_review_master_key'),
          secretEnvVar(key: 'DATABASE_HOST', secretName: 'jenkins-worker', secretKey: 'app_review_db_host'),
          secretEnvVar(key: 'DATABASE_USER', secretName: 'jenkins-worker', secretKey: 'app_review_db_username'),
          secretEnvVar(key: 'DATABASE_PASSWORD', secretName: 'jenkins-worker', secretKey: 'app_review_db_password'),
        ]
      )
    ]
  ) { label ->
    wrap.node("${label}") {
      checkoutScm()

      container('deploy') {
        sh """
          if [[ -n "\$(helm ls --failed -q "^${reviewName}\$")" ]]; then
            helm delete --purge "${reviewName}" || true
          fi
        """

        sh """
          helm upgrade --install \
            --wait \
            --timeout 600 \
            --set meta.changeId="${env.CHANGE_ID}" \
            --set meta.changeRepo="${jobName()}" \
            --set backend.image.tag="${env.GIT_COMMIT}" \
            --set frontend.image.tag="${env.GIT_COMMIT}" \
            --set ingress.domain="itsmycargo.tech" \
            --set masterKey=\$REVIEW_MASTER_KEY \
            --set postgres.host=\$DATABASE_HOST \
            --set postgres.user=\$DATABASE_USER \
            --set postgres.password=\$DATABASE_PASSWORD \
            --set postgres.database=${reviewName} \
            --namespace=review \
            "${reviewName}" \
            chart/
        """


      }
    }
  }
}

def knapsack(Integer ciNodeTotal, String label = 'slice', Closure body) {
  def slices = [:]

  for(int i = 0; i < ciNodeTotal; i++) {
    def index = i;
    slices["${label} ${index + 1}/${ciNodeTotal}"] = {
      withEnv(["CI_NODE_INDEX=$index", "CI_NODE_TOTAL=$ciNodeTotal"]) {
        body()
      }
    }
  }

  return slices
}

void cucumberTests() {
  inPod(
    containers: [
      containerTemplate(name: 'cucumber', image: "ruby:2.5.1-alpine", ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '250m', resourceLimitCpu: '400m',
        resourceRequestMemory: '600Mi', resourceLimitMemory: '700Mi'
      ),
      containerTemplate(name: 'selenium-hub', image: 'selenium/hub:3'),
      containerTemplate(name: 'selenium-chrome', image: 'selenium/node-chrome:3',
        resourceRequestCpu: '250m', resourceLimitCpu: '500m',
        resourceRequestMemory: '2000Mi', resourceLimitMemory: '2500Mi',
        envVars: [
          envVar(key: 'HUB_HOST', value: 'localhost'),
          envVar(key: 'SE_OPTS', value: '-port 5555')
        ]
      )
    ],
    volumes: [hostPathVolume(hostPath: '/dev/shm', mountPath: '/dev/shm')]
  ) { label ->
    retryOrAbort(2) {
      wrap.node(label) {
        checkoutScm()

        try {
          container('cucumber') {
            withEnv([
              'BROWSERNAME=chrome',
              'DRIVER=remote',
              "TARGET_URL=https://${env.REVIEW_NAME}.itsmycargo.tech"
            ]) {
              dir('qa/') {
                // Prepare
                sh "apk add --no-cache --update build-base"
                sh "bundle install -j\$(nproc) --retry 3"

                timeout(90) {
                  try {
                    sh "bundle exec knapsack cucumber \"--tags 'not @wip' --format junit --out . --format rerun --out rerun.txt --format pretty\""
                  } catch (hudson.AbortException e) {
                    if (e.getMessage().contains('script returned exit code 1') && findFiles(glob: 'rerun.txt').size() > 0) {
                      sh "bundle exec cucumber --format junit --out . --format pretty \$(cat rerun.txt)"
                    } else {
                      throw e
                    }
                  }
                }
              }
            }
          }
        } catch (err) {
          // Fetch Pod Logs
          podLog(namespace: 'review', selector: "app=imc-app,release=${env.REVIEW_NAME}", container: 'backend')
          podLog(namespace: 'review', selector: "app=imc-app,release=${env.REVIEW_NAME}", container: 'frontend')

          throw err
        } finally {
          junit allowEmptyResults: true, testResults: '**/*.xml'
          archiveArtifacts allowEmptyArchive: true, artifacts: '**/report/**/*'
        }
      }
    }
  }
}
