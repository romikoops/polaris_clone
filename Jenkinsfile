#!groovy

def label = "${UUID.randomUUID().toString()}"

wrap.pipeline {
  podTemplate(label: label, inheritFrom: 'default',
    containers: [
      containerTemplate(name: 'api', image: 'ruby:2.5-alpine3.8', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '1000m',
        resourceLimitCpu: '1500m',
        resourceRequestMemory: '1000Mi',
        resourceLimitMemory: '1500Mi',
        envVars: [
          envVar(key: 'POSTGRES_DB', value: 'imcr_test'),
          envVar(key: 'DATABASE_URL', value: 'postgis://postgres:@localhost/imcr_test')
        ]
      ),
      containerTemplate(name: 'client', image: 'node:10-alpine', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '1000m',
        resourceLimitCpu: '1200m',
        resourceRequestMemory: '1000Mi',
        resourceLimitMemory: '1200Mi',
      ),
      containerTemplate(name: 'danger', image: 'eu.gcr.io/itsmycargo-main/danger:latest', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '250m',
        resourceLimitCpu: '300m',
        resourceRequestMemory: '200Mi',
        resourceLimitMemory: '300Mi',
      ),
      containerTemplate(name: 'pronto', image: 'eu.gcr.io/itsmycargo-main/pronto:latest', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '250m',
        resourceLimitCpu: '300m',
        resourceRequestMemory: '200Mi',
        resourceLimitMemory: '300Mi',
      ),

      containerTemplate(name: 'postgis', image: 'mdillon/postgis',
        resourceRequestCpu: '250m',
        resourceLimitCpu: '500m',
        resourceRequestMemory: '400Mi',
        resourceLimitMemory: '500Mi',
      )
    ]
  ) {
    gitlabBuilds(builds: ['Test']) {
      wrap.node(label) {
        milestone()

        checkoutScm()

        gitlabCommitStatus(name: 'Test') {
          stage('Prepare') {
            milestone()

            parallel(
              api: {
                container('api') {
                  timeout(10) {
                    withEnv(["BUNDLE_GITLAB__COM=gitlab-ci-token:${GITLAB_TOKEN}"]) {
                      sh """
                        apk add --no-cache --update \
                          build-base \
                          cmake \
                          git \
                          linux-headers \
                          nodejs \
                          npm \
                          postgresql-dev \
                          tzdata
                        npm install -g 'mjml@4.2.0'
                      """
                      sh 'scripts/prepare'
                    }
                  }
                }
              },
              client: {
                container('client') {
                  timeout(10) {
                    sh """
                    apk add --no-cache --update \
                      autoconf automake bash build-base gifsicle lcms2-dev libjpeg-turbo-utils libpng-dev libtool libwebp-tools nasm optipng pngquant
                    """

                    dir('client') {
                      sh "npm install --no-progress"
                    }
                  }
                }
              }
            )
          }

          stage('Test & Code Style') {
            milestone()

            parallel(
              danger: {
                withEnv(["DANGER_GITLAB_API_TOKEN=${GITLAB_TOKEN}"]) {
                  container('danger') {
                    timeout(5) { sh 'danger' }
                  }
                }
              },
              pronto: {
                container('pronto') {
                  timeout(5) {
                    sh "pronto run -f checkstyle -c origin/${gitlabTargetBranch} --no-exit-code > checkstyle-result.xml"

                    ViolationsToGitLab([
                      apiToken: "${GITLAB_TOKEN}",
                      apiTokenPrivate: true,
                      authMethodHeader: true,

                      commentOnlyChangedContent: true,
                      createSingleFileComments: true,
                      gitLabUrl: 'https://gitlab.com',
                      keepOldComments: false,
                      mergeRequestIid: "${env.gitlabMergeRequestIid}",
                      projectId: "${env.gitlabMergeRequestTargetProjectId}",
                      shouldSetWip: true,
                      commentTemplate: "{{violation.message}}",
                      violationConfigs: [
                        [parser: 'CHECKSTYLE', pattern: '.*\\.xml$', reporter: 'Pronto']
                      ]
                    ])
                  }
                }
              },

              api: {
                container('api') {
                  timeout(10) {
                    withEnv(["BUNDLE_GITLAB__COM=gitlab-ci-token:${GITLAB_TOKEN}"]) {
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
                      dir('client') {
                        sh "npm run test:ci"
                      }
                    } catch (err) {
                      throw err
                    } finally {
                      junit allowEmptyResults: true, testResults: '**/junit.xml'
                      publishCoverage adapters: [istanbulCoberturaAdapter('**/cobertura-coverage.xml')]
                    }
                  }
                }
              }
            )
          }
        }
      }
    }
  }

  if (env.gitlabMergeRequestIid) {
    gitlabCommitStatus(name: 'Review') {
      stage('Prepare Deploy') {
        milestone()

        prepareDeploy()
      }

      stage('Deploy') {
        milestone()
        deployReview()
      }

      stage('QA') {
        milestone()

        timeout(45) {
          def jobs = [:]

          jobs << knapsack(2, 'Cucumber') { cucumberTests() }

          parallel jobs
        }
      }
    }
  }
}

void prepareDeploy() {
  def label = "${UUID.randomUUID().toString()}"

  podTemplate(label: "${label}", inheritFrom: 'default',
    envVars: [
      envVar(key: 'GOOGLE_APPLICATION_CREDENTIALS', value: '/etc/secrets/service-account/credentials.json'),
      envVar(key: 'DOCKER_DRIVER', value: 'overlay2'),
      envVar(key: 'DOCKER_HOST', value: 'tcp://localhost:2375/'),

    ],
    containers: [
      containerTemplate(name: 'docker', image: 'docker:dind', privileged: true, ttyEnabled: true,
        resourceRequestCpu: '1000m',
        resourceLimitCpu: '1200m',
        resourceRequestMemory: '4000Mi',
        resourceLimitMemory: '4500Mi',
      )
    ],
    volumes: [
      emptyDirVolume(memory: false, mountPath: '/var/lib/docker'),
      secretVolume(mountPath: '/etc/secrets/service-account', secretName: 'jenkins-worker-credentials'),
    ]
  ) {
    wrap.node("${label}") {
      checkoutScm()

      parallel(
        database: {
          build(
            job: 'Tasks/Production/review/dbreset',
            parameters: [string(name: 'database', value: "mr-${env.gitlabMergeRequestIid}")]
          )
        },
        api: {
          retry(2) {
            container('docker') {
              timeout(15) {
                sh """
                  rm -rf tmp/docker
                  mkdir -p tmp/docker
                  find . -depth -type f -name '*.gemspec' | cpio -d -v -p tmp/docker/
                """

                sh """
                  docker build \
                    --build-arg RELEASE=${env.gitlabMergeRequestLastCommit} \
                    --tag eu.gcr.io/itsmycargo-main/ci/imc-api:${env.gitlabMergeRequestLastCommit} \
                    .
                """

                sh "docker login -u _json_key --password-stdin eu.gcr.io/itsmycargo-main <\$GOOGLE_APPLICATION_CREDENTIALS"
                sh "docker push eu.gcr.io/itsmycargo-main/ci/imc-api:${env.gitlabMergeRequestLastCommit}"
              }
            }
          }
        },
        client: {
          retry(2) {
            container('docker') {
                timeout(15) {
                  dir('client') {
                    sh """
                    docker build \
                      --build-arg RELEASE=${env.gitlabMergeRequestLastCommit} \
                      --build-arg SENTRY_AUTH_TOKEN=099b9abd2844497db3dace7307576c12fadc7d47bd68416584cdb4b90709de95 \
                      --tag eu.gcr.io/itsmycargo-main/ci/imc-client:${env.gitlabMergeRequestLastCommit} \
                      .
                    """

                    sh "docker login -u _json_key --password-stdin eu.gcr.io/itsmycargo-main <\$GOOGLE_APPLICATION_CREDENTIALS"
                    sh "docker push eu.gcr.io/itsmycargo-main/ci/imc-client:${env.gitlabMergeRequestLastCommit}"
                  }
                }
              }
            }
          }
      )
    }
  }
}

void deployReview() {
  def label = "${UUID.randomUUID().toString()}"
  env.REVIEW_NAME = "mr-${env.gitlabMergeRequestIid}"

  podTemplate(label: "${label}", inheritFrom: 'default',
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
  ) {
    wrap.node("${label}") {
      checkoutScm()

      container('deploy') {
        sh """
          if [[ -n "\$(helm ls --failed -q "^${env.REVIEW_NAME}\$")" ]]; then
            helm delete --purge "${env.REVIEW_NAME}" || true
          fi
        """

        sh """
          helm upgrade --install \
            --wait \
            --timeout 600 \
            --set backend.image.tag="${env.gitlabMergeRequestLastCommit}" \
            --set frontend.image.tag="${env.gitlabMergeRequestLastCommit}" \
            --set ingress.domain="itsmycargo.tech" \
            --set masterKey=\$REVIEW_MASTER_KEY \
            --set postgres.host=\$DATABASE_HOST \
            --set postgres.user=\$DATABASE_USER \
            --set postgres.password=\$DATABASE_PASSWORD \
            --set postgres.database=${env.REVIEW_NAME} \
            --namespace=review \
            "${env.REVIEW_NAME}" \
            chart/
        """

        addGitLabMRComment comment: "Review app https://foo.itsmycaeto.tech"
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
  def label = "${UUID.randomUUID().toString()}"

  podTemplate(label: label, inheritFrom: 'default',
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
  ) {
    retry(2) {
      wrap.node(label) {
        checkoutScm()

        try {
          container('cucumber') {
            withEnv([
              'BROWSERNAME=chrome',
              'DRIVER=remote',
              "TARGET_URL=https://mr-${env.gitlabMergeRequestIid}.itsmycargo.tech"
            ]) {
              dir('qa/') {
                // Prepare
                sh "apk add --no-cache --update build-base"
                sh "bundle install -j\$(nproc) --retry 3"

                sh "bundle exec knapsack cucumber \"--tags 'not @wip' --format pretty --format junit --out .\""
              }
            }
          }
        } catch (err) {
          containerLog('selenium-cucumber')
          containerLog('selenium-hub')
          containerLog('selenium-chrome')

          throw err
        } finally {
          junit allowEmptyResults: true, testResults: '**/*.xml'
          archiveArtifacts allowEmptyArchive: true, artifacts: '**/report/**/*'
        }
      }
    }
  }
}
