# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security

- Detect Slack incoming webhook URLs and GitHub OAuth/App/refresh plus GitLab PAT shapes in the foundation secret-scan, including lockfiles that the inherited gitleaks default path allowlist skips.
