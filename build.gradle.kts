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
}
