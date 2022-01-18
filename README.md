# gitlab-repos-backup

## Usage

### Docker
```
$ docker run --rm \
    -e COMPRESSORS_TAR_ENABLED=true \
    -e TARGETS_AWS_S3_ENABLED=true \
    -e NOTIFIERS_SLACK_ENABLED=true \
    -e SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX \
    -e AWS_ACCESS_KEY_ID=XXXXXXXX \
    -e AWS_SECRET_ACCESS_KEY=XXXXXXXX \
    -e AWS_REGION=us-east-1 \
    -e S3_BACKUP_BUCKET=gitlab-backups-etc \
    -e GITLAB_ACCESS_TOKEN=XXXXXXXX \
    -e GITLAB_PROJECT_ID=my-gitlab-project \
    ghcr.io/bluesentry/gitlab-repos-backup
```

### Kubernetes CronJob

```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: gitlab-backup
spec:
  schedule: "0 0 * * *" # daily Midnight
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: gitlab-backup
              image: ghcr.io/bluesentry/gitlab-repos-backup
              imagePullPolicy: IfNotPresent
              env:
                - name: COMPRESSORS_TAR_ENABLED
                  value: "true"
                - name: TARGETS_AWS_S3_ENABLED
                  value: "true"
                - name: NOTIFIERS_SLACK_ENABLED
                  value: "true"
                - name: SLACK_WEBHOOK_URL
                  value: https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX
                - name: AWS_ACCESS_KEY_ID
                  value: XXXXXXXX
                - name: AWS_SECRET_ACCESS_KEY
                  value: XXXXXXXX
                - name: AWS_REGION
                  value: us-east-1
                - name: S3_BACKUP_BUCKET
                  value: gitlab-backups-etc
                - name: GITLAB_ACCESS_TOKEN
                  value: XXXXXXXX
                - name: GITLAB_PROJECT_ID
                  value: my-gitlab-project
          restartPolicy: OnFailure

```

### Gitlab CI/CD

```
# .gitlab-ci.yml

image: docker:19.03.12

services:
  - docker:19.03.12-dind

variables:
  # Define other secrets in "Settings > CI/CD > Variables"
  AWS_REGION: us-east-1
  S3_BACKUP_BUCKET: gitlab-backups-etc
  GITLAB_PROJECT_ID: my-gitlab-project
  COMPRESSORS_TAR_ENABLED: "true"
  NOTIFIERS_SLACK_ENABLED: "true"
  TARGETS_AWS_S3_ENABLED: "true"

job:on-schedule:
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
  script:
    - docker run --env COMPRESSORS_TAR_ENABLED --env TARGETS_AWS_S3_ENABLED --env NOTIFIERS_SLACK_ENABLED --env SLACK_WEBHOOK_URL --env AWS_ACCESS_KEY_ID --env AWS_SECRET_ACCESS_KEY --env AWS_REGION --env S3_BACKUP_BUCKET --env GITLAB_ACCESS_TOKEN --env GITLAB_PROJECT_ID ghcr.io/bluesentry/gitlab-repos-backup
```

### Github Actions

```
# .github/workflows/gitlab-backup.yaml

name: "gitlab-backup"
on:
  schedule:
    - cron:  '0 0 * * *' # daily Midnight

jobs:
  singleJobName:
    runs-on: ubuntu-latest
    steps:
      - name: Gitlab Backup
        run: |
          docker run --rm \
            -e COMPRESSORS_TAR_ENABLED=true \
            -e TARGETS_AWS_S3_ENABLED=true \
            -e NOTIFIERS_SLACK_ENABLED=true \
            -e SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX \
            -e AWS_ACCESS_KEY_ID=XXXXXXXX \
            -e AWS_SECRET_ACCESS_KEY=XXXXXXXX \
            -e AWS_REGION=us-east-1 \
            -e S3_BACKUP_BUCKET=gitlab-backups-etc \
            -e GITLAB_ACCESS_TOKEN=XXXXXXXX \
            -e GITLAB_PROJECT_ID=my-gitlab-project \
            ghcr.io/bluesentry/gitlab-repos-backup
```
