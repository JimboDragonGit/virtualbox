pipeline {
  agent { label 'svc_root' }

  environment {
    PATH = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin/:/root/.chef/gem/ruby/3.1.0/bin/'
  }

  parameters {
    string(name: 'Greeting', defaultValue: 'Hello', description: 'How should I greet the world?')
    string(name: 'chefrepo', defaultValue: 'default', description: 'chef')
    string(name: 'generator', defaultValue: '/chef/cookbooks/code_generator', description: 'code generator path')
  }

  stages {
    stage('Begin') {
        steps {
          wrap([$class: 'TimestamperBuildWrapper']) {
            echo 'Begin..'
            echo "${params.Greeting} World!"
            sh 'knife config show'
            sh 'chef show-policy builder_unix'
            sh 'chef show-policy builder_windows'
          }
        }
    }
    stage('Download') {
      steps {
        wrap([$class: 'TimestamperBuildWrapper']) {
          echo 'Download..'
        }
      }
    }
    stage('Verify') {
      steps {
        wrap([$class: 'TimestamperBuildWrapper']) {
          tool name: 'Default', type: 'git'
          echo 'Verify..'
        }
      }
    }
    stage('Clean') {
      steps {
        echo 'Clean..'
      }
    }
    stage('Unpack') {
      steps {
        echo 'Unpack..'
      }
    }
    stage('Prepare') {
      steps {
        echo 'Prepare..'
      }
    }
    stage('Build') {
      steps {
          echo 'Building..'
      }
    }
    stage('Check') {
      steps {
        echo 'Check..'
      }
    }
    stage('Install') {
      steps {
        echo 'Install..'
      }
    }
    stage('Strip') {
      steps {
        echo 'Strip..'
      }
    }
    stage('End') {
      steps {
        echo 'Finishing..'
      }
    }
  }
  post {
    always {
        sh 'rspec --format progress --format RspecJunitFormatter --out rspec.xml'
    }
    failure {
        echo 'The Pipeline failed :('
    }
  }
}
