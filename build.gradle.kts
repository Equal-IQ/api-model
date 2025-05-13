plugins {
    java
    id("software.amazon.smithy.gradle.smithy-jar").version("1.2.0")
}

repositories {
    mavenLocal()
    mavenCentral()
}

dependencies {
    implementation("software.amazon.smithy:smithy-openapi:1.56.0")
    implementation("software.amazon.smithy:smithy-cli:1.56.0")
    implementation("software.amazon.smithy:smithy-model:1.56.0") 
    implementation("software.amazon.smithy:smithy-build:1.56.0")
    
    // AWS API Gateway integration
    implementation("software.amazon.smithy.typescript:smithy-aws-typescript-codegen:0.20.0")
    implementation("software.amazon.smithy:smithy-aws-apigateway-traits:1.56.0")
    implementation("software.amazon.smithy:smithy-aws-traits:1.56.0")
}
