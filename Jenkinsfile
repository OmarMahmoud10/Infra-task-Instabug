pipeline
{
    agent
    {
        
        node
        {
            label 'built-in'
        }
    }
    environment
    {
        DOCKERHUB_CREDENTIALS= credentials('docker-credentials')     
    }

    stages
    {
        stage('Checkout')
        {
            steps
            {
                git branch: 'main', url: 'https://github.com/OmarMahmoud10/Infra-task-Instabug.git'
            }
            
        }
        stage('Docker-login')
        {
            steps
            {
                sh '''
                echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                echo "logged in successfullu"
                '''
            }
            
        }
        stage('Build')
        {
            steps
            {
                sh '''
                docker build -f Dockerfile . -t $DOCKERHUB_CREDENTIALS_USR/internship-go:$BUILD_NUMBER 
                echo "image build successfully"
                '''
            }
            
        }
        stage('PUSH')
        {
            steps
            {
                sh '''
                docker push $DOCKERHUB_CREDENTIALS_USR/internship-go:$BUILD_NUMBER
                '''


            }
        
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
        failure
        {  
            mail bcc: '', body: '<b>Pipeline build failed</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}"', cc: '', from: '', replyTo: '', subject: 'Pipeline Failed ', to: 'omar.mahmoud.ahmed10@gmail.com'  
        } 
    } 
}
