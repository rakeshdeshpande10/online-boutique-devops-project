module "vpc" {
    source = "./modules/vpc"

    region               = var.region
    cluster_name         = var.cluster_name
}

module "eks" {
    source = "./modules/eks"

    cluster_name         = var.cluster_name
    cluster_subnet_ids   = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
    node_subnet_ids      = module.vpc.private_subnet_ids
}

module "ecr" {
    source = "./modules/ecr"
}

module "github_oidc" {
    source = "./modules/github-oidc"

    ecr_repository_names = keys(module.ecr.ecr_repository_urls)
    region               = var.region
}