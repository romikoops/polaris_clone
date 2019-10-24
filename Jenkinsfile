#!groovy

withPipeline(timeout: 120) {
  inPod(
    containers: [
      containerTemplate(name: 'app', image: 'ruby:2.5', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '1000m', resourceLimitCpu: '1000m',
        resourceRequestMemory: '1500Mi', resourceLimitMemory: '1500Mi',
        envVars: [
          envVar(key: 'POSTGRES_DB', value: 'imcr_test'),
          envVar(key: 'DATABASE_URL', value: 'postgis://postgres:@localhost/imcr_test'),
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
      withStage('Checkout') {
        checkoutScm()

        // Stash for docker
        stash(name: 'backend', excludes: 'client/**/*,qa/**/*')
        stash(name: 'frontend', includes: 'client/**/*')
        stash(name: 'qa', includes: 'qa/**/*')
        if (fileExists("chart/Chart.yaml")) {
          stash(name: 'chart', includes: 'chart/**/*')
        }
      }

      withStage('Prepare') {
        milestone()

        parallel(
          app: { container('app') { appPrepare() } },
          client: { container('client') { clientPrepare() } }
        )
      }

      withStage('Test') {
        milestone()

        parallel(
          app: { container('app') { appRunner('app') } },
          engines: { container('app') { appRunner('engines') } },

          client: {
            container('client') {
              dir('client') {
                catchError(buildResult: null, stageResult: 'FAILURE') {
                  sh(label: 'Run Tests', script: 'npm run test:ci')
                }
              }
            }
          }
        )
      }

      withStage('Report', retry: false) {
        milestone()

        def ret = 0

        container('app') {
          ret = sh(label: 'Result Reporter', script: 'scripts/ci-results', returnStatus: true)
        }

        junit allowEmptyResults: false, testResults: "**/junit.xml"

        if (env.BRANCH_NAME == 'master') {
          publishCoverage adapters: [istanbulCoberturaAdapter('**/cobertura-coverage.xml')]
        }

        if (currentBuild.result != null || ret != 0) {
          error("Failed Tests")
        }
      }
    }
  }

  def prepareJobs = [:]

  // Always build images
  prepareJobs['images/qa'] = {
    withRetry {
      dockerBuild(dir: 'qa/', image: "${jobName()}/qa", memory: 1500, stash: 'qa')
    }
  }
  prepareJobs['images/backend'] = {
    withRetry {
      dockerBuild(
        dir: '.',
        image: "${jobName()}/backend",
        memory: 1500,
        stash: 'backend',
        pre_script: "scripts/docker-prepare.sh"
      )
    }
  }
  prepareJobs['images/frontend'] = {
    withRetry {
      dockerBuild(
        dir: 'client/',
        image: "${jobName()}/client",
        memory: 2000,
        args: [
          RELEASE: env.COMMIT_SHA,
          SENTRY_AUTH_TOKEN: '099b9abd2844497db3dace7307576c12fadc7d47bd68416584cdb4b90709de95'
        ],
        stash: 'frontend'
      )
    }
  }

  if (env.CHANGE_ID || env.GIT_BRANCH == 'master') {
    withStage('Docker Build') {
      inPod { label ->
        withNode(label) {
          parallel(prepareJobs)
        }
      }

      milestone()
    }
  }

  if (env.CHANGE_ID) {
    withStage('Deploy Review') {
      milestone()

      env.REVIEW_NAME = trimName(env.CI_COMMIT_REF_SLUG, 40)

      lock(resource: "deploy/${env.GIT_BRANCH}", inversePrecedence: true) {
        deployReview()

        milestone()
      }
    }

    // withStage('QA') {
    //   milestone()

    //   build(
    //     job: 'Voyage/imc-react-api',
    //     parameters: [
    //       string(name: 'APP_NAME', value: 'imc-app'),
    //       string(name: 'ENVIRONMENT', value: 'review'),
    //       string(name: 'NAMESPACE', value: 'review'),
    //       string(name: 'RELEASE', value: env.REVIEW_NAME),
    //       string(name: 'REPOSITORY', value: jobBaseName()),
    //       string(name: 'REVISION', value: env.GIT_COMMIT),
    //     ],
    //     wait: false
    //   )
    // }
  }
}

void appPrepare() {
  timeout(15) {
    withEnv(["BUNDLE_GITHUB__COM=pierbot:${env.GITHUB_TOKEN}", "LC_ALL=C.UTF-8", "BUNDLE_PATH=${env.WORKSPACE}/vendor/ruby"]) {
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
        sh(label: 'Install Gems', script: "scripts/ci-prepare")
      }
    }
  }
}

void clientPrepare() {
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

void appRunner(String name) {
  withEnv(["BUNDLE_GITHUB__COM=pierbot:${env.GITHUB_TOKEN}", "LC_ALL=C.UTF-8", "BUNDLE_PATH=${env.WORKSPACE}/vendor/ruby"]) {
    catchError(buildResult: null, stageResult: 'FAILURE') {
      sh(label: 'Test', script: "scripts/ci-test ${name}")
    }
  }
}
