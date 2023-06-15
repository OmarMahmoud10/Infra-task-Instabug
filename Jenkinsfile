pipeline
{
    agent
    {
        node
        {
            label ''
        }
    }
    environment
    {
        DOCKERHUB_CREDENTIALS= credentials('docker-credentials')     
    }
    triggers
    {
        pollSCM '*H/1****'
    }
    stages
    {
        stage('Checkout')
        {
            git branch: 'main', url: 'https://github.com/OmarMahmoud10/Infra-task-Instabug.git'
        }
        stage('Docker-login')
        {
            sh '''
            echo $DOCKERHUB_CREDENTIALS_PSW | sudo docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
            echo "logged in successfullu"
            '''
        }
        stage('Build')
        {
            sh '''
                docker build -f Dockerfile -t $DOCKERHUB_CREDENTIALS_USR/internship-go:$BUILD_NUMBER 
                echo "image build successfully"
            '''
        }
        stage('PUSH')
        {
            sh '''
            docker push $DOCKERHUB_CREDENTIALS_USR/internship-go:$BUILD_NUMBER
            '''

        }
    }
    post
    {
        always
        {
            sh '''
            docker logout
            '''
        }
        faliure
        {  
        mail bcc: '', body: "<b>Example</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "ERROR CI: Project name -> ${env.JOB_NAME}", to: "foo@foomail.com";  
        } 
    } 
}