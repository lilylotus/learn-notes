#### 1. pipline

```groovy
pipeline {
    agent any

    tools {
        gradle 'gradle'
    }
    
    /* environment{} 环境变量,键值对
    	作用范围: 顶层环境变量，所有 stage 下 step 共享这些变量
    		单独定义在某一个 stage 下，只能供这个 stage 去调用变量
    	如果是局部环境变量，直接用 def 关键字声明就可以
    */
    environment {
        param1 = true
    }

    stages {
        stage('Build') {
            steps {

                script {
                    if (param1 == true) {
                        echo "param1 is true"   
                    }
                    
                    println env.WORKSPACE
                }
                
                /* 改变当前的工作目录，在 dir 语句块里执行的其它路径或者相对路径 */
                dir('pipline_project') {
                    git credentialsId: '2a98d47c-9aea-4e00-8377-ad59cda6ffff', url: 'http://10.10.100.6/luck/jenkins-project.git'
                    sh "pwd"
                }
                
                sh("ls -al ${env.WORKSPACE}")
                
                /* 默认递归删除 WORKSPACE 下的文件和文件夹，没有参数
                	删除当前目录下所有文件
                */
                deleteDir()
                
                sh("ls -al ${env.WORKSPACE}")

                // Run Maven on a Unix agent.
                //sh "mvn -Dmaven.test.failure.ignore=true clean package"

                // To run Maven on a Windows agent, use
                // bat "mvn -Dmaven.test.failure.ignore=true clean package"
            }
        }
    }
}
```

