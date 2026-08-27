# Online Boutique — CI/CD on AWS EKS with Terraform, GitHub Actions & Argo CD

This project takes Google's [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) microservices demo application and builds a complete, production-style DevOps pipeline around it: infrastructure provisioned with Terraform, a CI pipeline in GitHub Actions that builds, scans, and pushes five of the application's microservices, and Argo CD handling GitOps-based continuous deployment to AWS EKS.

The application code itself (all 11 microservices) is Google's, licensed under Apache 2.0 — see [Attribution](#attribution) below. The infrastructure, CI/CD pipeline, containerization, security scanning, and GitOps deployment are original work for this project.

## What this project demonstrates

- **Infrastructure as Code** — VPC, EKS cluster, ECR repositories, and OIDC-based IAM roles, all provisioned via modular Terraform (no long-lived AWS credentials in CI)
- **CI pipeline** — per-service change detection, build/test/lint, Docker image builds, vulnerability scanning, and automated push to ECR — for 5 of the 11 services
- **GitOps CD** — Argo CD watches a Helm chart and syncs the cluster to match Git, with CI updating image tags in the chart automatically
- **Security scanning** — Trivy (image + IaC config scanning) and Gitleaks (secret scanning) wired into the pipeline
- **Real debugging** — this README documents actual issues hit and fixed along the way (see [Issues & Fixes](#issues--fixes-along-the-way)), not just a working happy path

## Architecture

![Architecture](/docs/img/cicd_eks_architecture.png)

Terraform provisions the VPC (4 subnets across 2 AZs, NAT/IGW), the EKS cluster and node group, 5 ECR repositories, and a GitHub OIDC provider + IAM role scoped to this repo — so GitHub Actions authenticates to AWS without stored credentials.

## Microservices

Of the 11 services in the original application, this project built a full CI/CD pipeline for 5 (the rest run using Google's original manifests/images, unmodified):

| Service | Language | CI/CD built? | Notes |
|---|---|---|---|
| [frontend](/src/frontend) | Go | ✅ | build/test, lint |
| [checkoutservice](/src/checkoutservice) | Go | ✅ | build/test, lint |
| [recommendationservice](/src/recommendationservice) | Python | ✅ | no test/lint (upstream code) |
| [currencyservice](/src/currencyservice) | Node.js | ✅ | no test/lint (upstream code) |
| [adservice](/src/adservice) | Java | ✅ | Java 21 via setup-java |
| cartservice | C# | — | deployed as-is |
| productcatalogservice | Go | — | deployed as-is |
| paymentservice | Node.js | — | deployed as-is |
| shippingservice | Go | — | deployed as-is |
| emailservice | Python | — | deployed as-is |
| loadgenerator | Python/Locust | — | deployed as-is |

## Pipeline stages (per service)

1. **Change detection** — [`dorny/paths-filter`](https://github.com/dorny/paths-filter) triggers only the jobs for services actually changed
2. **Build/test/lint** — language-appropriate steps (Go, Python, Node.js, Java)
3. **Docker build** — multi-stage builds, non-root users, pinned base image versions
4. **Trivy image scan** — vulnerability scanning (report-only for app images; blocking for Terraform IaC config)
5. **OIDC authentication to AWS** — short-lived credentials, no static keys
6. **Push to ECR** — image tagged with the Git commit SHA
7. **Update Helm values** — pipeline commits the new image tag to `helm-chart/values.yaml`
8. **Argo CD sync** — detects the Git change and rolls it out to EKS

Additional pipeline-wide checks: **Gitleaks** for secret scanning, and a **Trivy config scan** on the `terraform/` directory for IaC misconfigurations (blocking on HIGH/CRITICAL).

## Repo structure

```
.
├── src/                    # microservices source (Google's app code)
├── protos/                 # gRPC protocol buffer definitions
├── helm-chart/             # Helm chart deployed by Argo CD
├── terraform/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── eks/
│   │   ├── ecr/
│   │   └── github-oidc/
│   └── (root config)
├── .github/workflows/
│   └── ci-cd.yml
└── docs/
```

## Issues & fixes along the way

A few of the real problems hit while building this, since a pipeline that "just works" on the first try usually means something wasn't tested:

- **GitHub's OIDC token format change** — GitHub rolled out an "immutable IDs" format for the `sub` claim mid-project (`repo:org@actor_id/repo@repository_id:ref:...`), which silently broke the IAM trust policy's `StringLike` condition. Root-caused after ruling out session-tagging and eventual-consistency theories; fixed by updating the Terraform-managed trust policy to match the new format.
- **Parallel job race condition on `values.yaml`** — all 5 service jobs run in parallel and each needs to commit an updated image tag to the same Helm values file, so concurrent pushes were getting rejected. Fixed with a rebase-and-retry loop (up to 5 attempts with backoff) rather than serializing the jobs.
- **File mode drift blocking a rebase** — `adservice`'s `gradlew` was committed as non-executable; CI's `chmod +x` created an unstaged permission change that blocked `git pull --rebase`. Fixed by committing the executable bit properly rather than patching it at runtime.
- **False-positive lint findings on generated code** — `golangci-lint`'s `copylocks` check flagged 41 false positives in Google's protobuf-generated `checkoutservice` code (an inert embedded mutex). Fixed by scoping the check off for that package with a documented `.golangci.yml`, rather than editing 41 call sites.
- **Scan scope tuning** — Trivy image scans for the five services started as blocking, but surfaced a large volume of upstream demo-app dependency CVEs that weren't practical to patch without touching Google's application code. Switched app-image scans to report-only while keeping the Terraform IaC config scan blocking, since infrastructure misconfigurations are what this project is actually responsible for.

## Load balancer note

The frontend is exposed via a Kubernetes `Service` of type `LoadBalancer`. On EKS this provisions a **Classic Load Balancer** automatically through the cluster's cloud-controller-manager — this happens outside Terraform, since it's a Kubernetes-native resource, not a Terraform-managed one. A natural next step would be installing the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) and switching to an `Ingress` resource for ALB-based routing.

## Screenshots

*(Add captured screenshots here — homepage, checkout flow, GitHub Actions run, Argo CD sync view)*

## Future improvements

- Remote Terraform state (S3 + DynamoDB locking) instead of local state
- AWS Load Balancer Controller + Ingress (ALB) instead of the default Classic Load Balancer
- Extend CI/CD to the remaining 6 services
- SAST scanning (e.g. SonarQube) across all languages

## Attribution

The application source code under `src/` and `protos/` originates from Google's [Online Boutique / microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo), licensed under [Apache License 2.0](https://github.com/GoogleCloudPlatform/microservices-demo/blob/main/LICENSE). All Terraform infrastructure code, the GitHub Actions CI/CD pipeline, Dockerfile rewrites, Helm chart customization, and Argo CD/GitOps setup in this repository are original work built on top of that application as a DevOps learning project.
