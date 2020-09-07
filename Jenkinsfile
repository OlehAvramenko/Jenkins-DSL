pipeline {
    agent none
#  ================== ADD ENV ==================
    environment {
      REGION = 'us-east-1'
      REGISTRY = '427050172059.dkr.ecr.us-east-1.amazonaws.com/foxtrot'
      BUCKET = 'demo3-dependency-m2'
    }
# ==================== ADD REPO ======================
    scm {
git {
remote {
    name('main')
    url('ssh://git@main.gitlab.in.here.com:3389/avramenk/spring-petclinic.git')
    credentials('Avramenko, Oleh (avramenko)')
    }
  }
}


    stages {
        stage('build-main') {
          agent {
            foxtrot_build
          }
            steps {
                sh 'sudo usermod -aG docker ubuntu \
                  sudo chmod 666 /var/run/docker.sock \
                  [ ! -d "${WORKSPACE}/.m2" ]  && mkdir -p ${WORKSPACE}/.m2 \
                  aws s3 sync  s3://${BUCKET}/.m2 ${WORKSPACE}/.m2/ \
                  # Create image from docker file \
                  DOCKER_BUILDKIT=1 docker build . --tag petclinic-app:${BUILD_NUMBER} -f docker/docker_APP/Dockerfile --progress=plain \
                  aws s3 sync ${WORKSPACE}/.m2/ s3://${BUCKET}/.m2'
                }


        }
    }
}
