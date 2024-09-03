# OpenTofu Github Actions

[OpenTofu](https://opentofu.org/docs/intro/) lets you configure all manner of resources using infrastructure as code.  This repo template helps you run `tofu` via `docker compose` using `make`, both in your local development environment and Github Actions.

For small teams this approach keeps everything within Github, making it less complicated then using [remote state](https://opentofu.org/docs/language/state/remote/) and/or external [TACOS](https://opentofu.org/docs/intro/tacos/) platforms.

## Overview

### Local Development

Make configuration changes in your local development environment on a git feature branch, and confirm your planned changes.

---

```sh
$ make tofu_plan
OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

OpenTofu will perform the following actions:

  # null_resource.hello-world will be created
  + resource "null_resource" "hello-world" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### Feature Branch Pull Request

Upon pushing your feature branch and opening a pull request, Github Actions runs the plan and adds its output as a comment on the pull request (it should be the same as in local development).

---

> OpenTofu Plan 📖success

```sh
OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

OpenTofu will perform the following actions:

  # null_resource.hello-world will be created
  + resource "null_resource" "hello-world" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

> If you are happy with the plan and want to kick off the apply workflow, approve this pull request or add a comment with the string `approved`.

### Pull Request Approval

Once the plan output is satisfactory, and you approve the pull request, Github Actions will apply the configuration, again adding its output as a comment on the pull request.

---

> OpenTofu Apply 🛠️success
>
> State File Git Commit 🤖success

```sh
null_resource.hello-world: Creating...
null_resource.hello-world: Provisioning with 'local-exec'...
null_resource.hello-world (local-exec): Executing: ["/bin/sh" "-c" "echo Hello World!"]
null_resource.hello-world (local-exec): Hello World!
null_resource.hello-world: Creation complete after 0s [id=3149995933108895348]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

> If you are happy with the apply, merge away!

### Pull Request Merge

Once the apply succeeds, merge the pull request.

## Getting Started

### Fork This Repo

Fork this repo so you have your own git repository and check it out locally.

### Create/Edit `.env`

After git checkout:

- copy `.env.example` to `.env`
- set the value of `STATE_ENCRYPTION_PASSPHRASE` in `.env`

Run `make` to show available commands (which are defined in `.env`):

```yaml
$ make
docker-compose-build:  run docker compose build
docker-compose-down:   run docker compose down
docker-compose-up:     run docker compose up
help:                  list all make commands
shell:                 run shell to access tofu command directly
tofu_apply:            run tofu apply (if plan was run recently)
tofu_fmt:              run tofu fmt -diff
tofu_fmt_check:        run tofu fmt -check -diff
tofu_init:             run tofu init
tofu_init_upgrade:     run tofu init -upgrade to upgrade providers
tofu_output:           run tofu output
tofu_plan:             run tofu plan
tofu_plan_drift:       run tofu plan -detailed-exit-code
tofu_show_plan:        run tofu show -no-color tfplan
tofu_version:          run tofu version
```

### Local Development Of OpenTofu Configuration

The OpenTofu configuration is found under the `src/` directory.

The usual OpenTofu init/plan/apply/fmt workflow is used, but we run them via make:

- `make tofu_init`
- `make tofu_plan`
- `make tofu_apply` (only run in Github Actions)
- `make tofu_fmt_check` - use `make tofu_fmt` to automate corrections

Make your changes, ensuring you're happy with the output of `make tofu_plan`.

Git add/commit/push to your feature branch.

> Note: you can run further tofu commands by dropping into the shell (`make shell`).

## Github Actions

### Workflows

We have 4 Github Actions workflows:

1. __Format Check__ - checks OpenTofu syntax on feature branch pushes
2. __Plan__ - runs `tofu plan` when a pull request is created
3. __Apply__ - runs `tofu apply` after a pull request has been approved
4. __Drift Detection__ - scheduled daily check to identify unexpected plan changes

> The Github Actions workflows are based on:

- <https://medium.com/@gallaghersam95/the-best-terraform-cd-pipeline-with-github-actions-6ecbaa5f3762>
- <https://spacelift.io/blog/github-actions-terraform>
- <https://rtfm.co.ua/en/github-actions-terraform-deployments-with-a-review-of-planned-changes/>
- <https://dev.to/zirkelc/trigger-github-workflow-for-comment-on-pull-request-45l2>

### Secrets and Variables

Ensure you have `TF_VAR_STATE_ENCRYPTION_PASSPHRASE` configured as a repository secret for Github Actions, __Settings -> Secrets and variables -> Actions__.

## Useful Information

### OpenTofu State

The (encrypted) OpenTofu state file is commited to the git repo at `src/terraform.tfstate`.

Updates to the state file are done via the `Apply` Github Actions workflow, `.github/workflows/apply.yml` as a commit by `github-actions[bot]`.

The Github Actions workflows are limited to running one workflow job at at time to ensure the consistency of the state file. By only running plans in local development, there is no concerns with state consistency (It is recommended __not__ to run apply in local development).
