pipeline {
  agent { label 'svc_root' }

  environment {
    PATH = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin/:/root/.chef/gem/ruby/3.1.0/bin/'
  }

  stages {
    stage('Begin') {
        steps {
          wrap([$class: 'TimestamperBuildWrapper']) {
            echo 'Begin..'
            echo "${params.Greeting} World!"
            sh 'gem update --system'
            sh 'chef shell-init bash'
            sh 'knife config show'
            sh 'chef show-policy builder_unix'
            sh 'chef show-policy builder_windows'
            sh 'rake --tasks'
            sh 'rake --tasks --all'
          }
        }
    }
    stage('Download') {
      steps {
        wrap([$class: 'TimestamperBuildWrapper']) {
          echo 'Download..'
          sh 'bundle install'
          sh 'ls -alh /var/svc_root/workspace/Cookbooks'
          sh 'rake'
        }
      }
    }
    stage('Verify') {
      steps {
        wrap([$class: 'TimestamperBuildWrapper']) {
          tool name: 'Default', type: 'git'
          echo 'Verify..'
          sh 'knife cookbook show virtualbox'
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
        wrap([$class: 'TimestamperBuildWrapper']) {
          tool name: 'Default', type: 'git'
          echo 'Build..'
        }
      }
    }
    stage('Check') {
      steps {
        echo 'Check..'
      }
    }
    stage('Install') {
      steps {
        wrap([$class: 'TimestamperBuildWrapper']) {
          tool name: 'Default', type: 'git'
          echo 'Build..'
        }
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
