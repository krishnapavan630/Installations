# Installation Scripts

This repository contains installation scripts for setting up commonly used **DevOps tools on Linux machines**. These scripts are intended for learning, hands-on practice, and quickly preparing Linux environments.

## Available Installations

The repository includes installation scripts for tools such as:

* Jenkins
* Nexus Repository
* Docker
* Trivy
* Other DevOps tools and dependencies

## Prerequisites

Before running the installation scripts, make sure you have:

* A Linux machine or cloud instance
* `sudo` or root privileges
* Internet connectivity

> **Note:** Install **Java** before installing tools that require it, such as **Jenkins**.

For **Amazon Linux 2023**, Java 21 (Amazon Corretto) can be installed using:

```bash
sudo dnf install java-21-amazon-corretto -y
```

Verify the installation:

```bash
java -version
```

## Running an Installation Script

Make the required script executable:

```bash
chmod +x <script-name>.sh
```

Run the script:

```bash
sudo ./<script-name>.sh
```

## Troubleshooting

### Nexus Repository

View the latest Nexus logs:

```bash
sudo tail -n 100 /opt/sonatype-work/nexus3/log/nexus.log
```

Follow the Nexus logs in real time:

```bash
sudo tail -f /opt/sonatype-work/nexus3/log/nexus.log
```

## Useful Jenkins Plugins

The following Jenkins plugins may be useful when building CI/CD pipelines:

1. **Pipeline: Stage View** — Visualizes the stages of a Jenkins Pipeline.
2. **Deploy to Container** — Deploys build artifacts such as WAR files to application servers such as Tomcat.
3. **SonarQube Scanner** — Integrates Jenkins pipelines with SonarQube for code quality analysis.
4. **Nexus Artifact Uploader** — Uploads build artifacts to Nexus Repository.
5. **Blue Ocean** — Provides an alternative visual interface for Jenkins pipelines.
6. **Matrix Authorization Strategy** — Provides fine-grained, user- and group-based permissions.
7. **Email Extension Plugin** — Provides configurable email notifications for Jenkins jobs and pipelines.

## Purpose

This repository is maintained as part of my **DevOps learning and hands-on practice**, with reusable scripts for quickly setting up Linux environments.
