```groovy
properties([
    parameters([
        gitParameter(branch: '',
            branchFilter: 'origin/(.*)',
            defaultValue: 'develop',
            description: '',
            name: 'BRANCH',
            quickFilterEnabled: false,
            selectedValue: 'NONE',
            sortMode: 'NONE',
            tagFilter: '*',
            type: 'PT_BRANCH')
    ])
])

def getRemoteServer(ip){
    def remote = [:]
    remote.name = ip
    remote.host = ip
    remote.port = 22
    remote.allowAnyHosts = true
    withCredentials([usernamePassword(credentialsId: 'ssh_idaas', passwordVariable: 'password', usernameVariable: 'userName')]) {
        remote.user = "${userName}"
        remote.password = "${password}"
    }
    return remote
}

pipeline {

    agent {
        docker {
            image 'docker.koal.com/java/java-builder:openjdk-8-gradle-6.5-dockercli-19.03'
            alwaysPull true
            args '-v $HOME/.gradle/dependency-check-data:/root/.gradle/dependency-check-data:z -u root'
            reuseNode true
        }
    }

    environment {
        APP_NAME = sh(script: 'cat gradle.properties | grep -E "^artifactId=" | awk -F "=" \'{print $2}\'',
                      returnStdout: true).trim()
        APP_VERSION = sh(script: 'cat gradle.properties | grep -E "^version=" | awk -F "=" \'{print $2}\'',
                              returnStdout: true).trim()
        SERVICE_PORT = sh(script: 'cat src/main/resources/application.yml | grep -E "^  port: " | awk \'{print $2}\'',
                       returnStdout: true).trim()
        DOCKER_REPO = 'docker.koal.com'
        SONAR_HOST_URL = 'http://10.0.109.129:9000'
        SONAR_ADMIN_AUTH = 'admin:root123'
        SONAR_QUALITY_GATE_NAME = "idaas-quality-gate"
        GIT_AUTHOR_NAME = sh(script: 'git --no-pager show -s --format=\'%an\'',
                            returnStdout: true).trim()
        GIT_COMMIT_ID = sh(script: 'git rev-parse HEAD',
                        returnStdout: true).trim()
    }

    options {
          gitLabConnection('idaas-gitlab-conn')
          timeout(time: 20, unit: 'MINUTES')
          disableConcurrentBuilds()
    }

    triggers {
          gitlab(triggerOnPush: true,
           triggerOnMergeRequest: true,
           branchFilterType: 'All')
    }

    stages {

        stage('unit-test') {

            when {
                not {
                    anyOf {
                        // 只是为了维护 test 和 doc 环境，所以就忽略 test 和 doc 的单元测试
                        branch 'test'
                        branch 'doc'
                    }
                }
            }

            steps {
                updateGitlabCommitStatus name: 'unit-test', state: 'running'

                isUnix()
                sh '''#!/bin/bash
                    set -eo pipefail

                    echo "WORKSPACE:${WORKSPACE}"
                    echo "GIT_BRANCH:${GIT_BRANCH}"
                    java -version

                    # 尝试合并主分支，检测是否有冲突
                    git checkout develop
                    git merge ${GIT_BRANCH} --no-commit --no-ff

                    # 在 develop 分支单元测试的前，先删除旧分支的sonar工程
                    MERGE_FROM_BRANCH_NAME=$((git log -1 | grep "Merge branch" || true) | awk '{print $3}' | sed "s/'//g")
                    if [[ "${GIT_BRANCH}" == "develop" && "${MERGE_FROM_BRANCH_NAME}" != "" ]]; then
                        curl -s -u ${SONAR_ADMIN_AUTH} -X POST "${SONAR_HOST_URL}/api/projects/delete?project=${APP_NAME}:${MERGE_FROM_BRANCH_NAME}" || true ;
                    fi

                    gradle clean --warning-mode all
                    gradle compileJava 2>&1 | tee compileJava.out
                    if [[ "$(grep -c ': warning: ' compileJava.out)" > "0" ]]; then
                        echo "error: must be no compile warning"
                        exit 1
                    fi
                    gradle test
                    gradle jacocoTestReport
                    '''
                    //                     gradle dependencyCheckAnalyze -i
                withSonarQubeEnv('sonar-109.129') {
                    sh '''#!/bin/bash
                        set -eo pipefail

                        SONAR_PROJECT_KEY=${APP_NAME}
                        if [[ "${GIT_BRANCH}" != "develop" ]]; then SONAR_PROJECT_KEY=${SONAR_PROJECT_KEY}:${GIT_BRANCH}; fi

                        # 设置质量阈值为指定的配置
                        curl -s -X POST "${SONAR_HOST_URL}/api/projects/create?key=${SONAR_PROJECT_KEY}&name=${SONAR_PROJECT_KEY}"
                        SONAR_PROJECT_ID=`curl -s "${SONAR_HOST_URL}/api/components/show?component=${SONAR_PROJECT_KEY}" | grep -oE \\"id\\":\\"[^\\"]*\\" | head -n 1 | awk -F '\\"' '{print $4}'`
                        SONAR_QUALITY_GATE_ID=`curl -s "${SONAR_HOST_URL}/api/qualitygates/show?name=${SONAR_QUALITY_GATE_NAME}" | grep -oE \\"id\\":[0-9]+ | head -n 1 | awk -F ':' '{print $2}'`
                        curl -s -X POST -u ${SONAR_ADMIN_AUTH} "${SONAR_HOST_URL}/api/qualitygates/select?gateId=${SONAR_QUALITY_GATE_ID}&projectId=${SONAR_PROJECT_ID}"

                        gradle sonarqube -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.projectKey=${SONAR_PROJECT_KEY} -Dsonar.projectName=${SONAR_PROJECT_KEY}
                        '''
                }
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                    // 删除sonar上的分支项目
                    sh '''#!/bin/bash
                        set -eo pipefail

                       SONAR_PROJECT_KEY=${APP_NAME}
                       if [[ "${GIT_BRANCH}" != "develop" ]]; then SONAR_PROJECT_KEY=${SONAR_PROJECT_KEY}:${GIT_BRANCH}; fi
                       if [[ "${GIT_BRANCH}" != "develop" ]]; then curl -s -u ${SONAR_ADMIN_AUTH} -X POST "${SONAR_HOST_URL}/api/projects/delete?project=${SONAR_PROJECT_KEY}"; fi
                       '''
                }

                junit 'build/test-results/test/**/*.xml'
            }

            post {
                unsuccessful {
                    updateGitlabCommitStatus name: 'unit-test', state: 'failed'
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'build', excludes: 'build/libs', followSymlinks: false
                }
                success {
                    updateGitlabCommitStatus name: 'unit-test', state: 'success'
                }
            }

        }
        stage('build') {

            when {
                allOf {
                    anyOf {
                        branch 'develop'
                    }
                }
            }

            steps {
                updateGitlabCommitStatus name: 'build', state: 'running'

                isUnix()

                withCredentials([usernamePassword(credentialsId: 'robot$idaas-pusher', passwordVariable: 'password', usernameVariable: 'userName')]) {
                    sh '''#!/bin/bash
                    docker login ${DOCKER_REPO} -u "${userName}" -p "${password}"
                    '''
                }

                sh '''#!/bin/bash
                    echo "WORKSPACE:${WORKSPACE}"
                    echo "GIT_BRANCH:${GIT_BRANCH}"
                    java -version

                    gradle bootJar

                    # push latest version
                    chmod +x src/main/docker/*.sh
                    docker build --pull -f src/main/docker/Dockerfile \
                        --build-arg DEF_APP_NAME=${APP_NAME} \
                        --build-arg DEF_SERVICE_PORT=${SERVICE_PORT} \
                        --build-arg DEF_APP_GIT_COMMIT_ID=${GIT_COMMIT_ID} \
                        -t ${DOCKER_REPO}/idaas/${APP_NAME}:latest .
                    docker push ${DOCKER_REPO}/idaas/${APP_NAME}:latest

                    # push build-id version
                    docker tag ${DOCKER_REPO}/idaas/${APP_NAME}:latest ${DOCKER_REPO}/idaas/${APP_NAME}:${BUILD_ID}
                    docker push ${DOCKER_REPO}/idaas/${APP_NAME}:${BUILD_ID}

                    # push version
                    docker tag ${DOCKER_REPO}/idaas/${APP_NAME}:latest ${DOCKER_REPO}/idaas/${APP_NAME}:${APP_VERSION}
                    docker push ${DOCKER_REPO}/idaas/${APP_NAME}:${APP_VERSION}
                    '''
            }

            post {
                unsuccessful {
                    updateGitlabCommitStatus name: 'build', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'build', state: 'success'
                }
            }
        }

        stage('apply-dev-env') {
            when {
                allOf {
                    anyOf {
                        branch 'develop'
                    }
                }
            }
            environment {
                ENV_HOST = '10.0.248.28'
                SW_AGENT_COLLECTOR_BACKEND_SERVICES="10.0.248.31:11800"
                NACOS_ADDR = '10.0.248.38:8848'
                ACTIVE='dev'
            }

            steps {
                updateGitlabCommitStatus name: 'apply-dev-env', state: 'running'

                sshCommand remote: getRemoteServer("${ENV_HOST}") ,
                    command: "docker rmi -f `docker images | awk 'NR>1 {print \$3}'` || echo none"
                sshCommand remote: getRemoteServer("${ENV_HOST}") ,
                    command: "docker container stop `docker container ls -a|grep ${APP_NAME}-${ACTIVE}|awk '{print \$1}'`  > /dev/null 2>&1 || echo none"
                sshCommand remote: getRemoteServer("${ENV_HOST}") ,
                    command: "docker container rm `docker container ls -a|grep ${APP_NAME}-${ACTIVE}|awk '{print \$1}'`  > /dev/null 2>&1|| echo none"
                sshCommand remote: getRemoteServer("${ENV_HOST}") ,
                    command: "docker pull ${DOCKER_REPO}/idaas/${APP_NAME}:${APP_VERSION}"
                sshCommand remote: getRemoteServer("${ENV_HOST}") ,
                    command: "docker run -d \
                     --restart unless-stopped \
                     --network host \
                     -e SW_AGENT_COLLECTOR_BACKEND_SERVICES=${SW_AGENT_COLLECTOR_BACKEND_SERVICES} \
                     -e NACOS_ADDR=${NACOS_ADDR} \
                     -e ACTIVE=${ACTIVE} \
                     --name ${APP_NAME}-${ACTIVE} \
                     ${DOCKER_REPO}/idaas/${APP_NAME}:${APP_VERSION}"

            }

            post {
                unsuccessful {
                    updateGitlabCommitStatus name: 'apply-dev-env', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'apply-dev-env', state: 'success'
                }
            }
        }
    }

    post {
        always {
            cleanWs(cleanWhenAborted: true,
                cleanWhenFailure: true,
                cleanWhenNotBuilt: true,
                cleanWhenSuccess: true,
                cleanWhenUnstable: true,
                cleanupMatrixParent: true,
                deleteDirs: true,
                disableDeferredWipeout: true,
                skipWhenFailed: true)
        }

        success {
            dingTalk(robot:'cbd655e9-7efd-4712-b47b-210eb21808a8',
                type:'LINK',
                title:"构建成功：${JOB_NAME} #${BUILD_NUMBER}",
                text:["持续时间：${currentBuild.durationString}；执行人：@${GIT_AUTHOR_NAME}"],
                picUrl:"https://s1.ax1x.com/2020/10/22/BiDhxe.jpg",
                messageUrl:"${JOB_URL}"
               )
        }

        unsuccessful {
            dingTalk(robot:'cbd655e9-7efd-4712-b47b-210eb21808a8',
                type:'LINK',
                title:"构建失败：${JOB_NAME} #${BUILD_NUMBER}",
                text:["持续时间：${currentBuild.durationString}；执行人：@${GIT_AUTHOR_NAME}"],
                picUrl:"https://s1.ax1x.com/2020/10/22/BirmL9.jpg",
                messageUrl:"${JOB_URL}"
            )
        }
    }

}

```

