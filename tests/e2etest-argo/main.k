import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1

_items = [
    metav1alpha1.E2ETest{
        metadata.name: "argocd-e2e-test"
        spec= {
            crossplane.autoUpgrade.channel: "None"
            crossplane.version = "2.1.3-up.1"
            defaultConditions: ["Ready"]
            manifests: [
                gitopsv1alpha1.Argo {
                    metadata = {
                        name = "test-argocd-instance"
                        namespace = "solutions-e2e-argocd"
                    }
                    spec = {
                        parameters = {
                            providerConfigName = "uptest-gitops-argocd-cluster"
                            managementPolicies = ["*"]
                            operators = {
                                argocd = { version = "7.1.1" }
                            }
                            source = {
                                git = {
                                    url = "https://github.com/upbound/configuration-gitops-argocd.git"
                                    path = "gitops"
                                    ref = {
                                        name = "HEAD"
                                    }
                                }
                            }
                        }
                    }
                }
            ]
            extraResources: [
                # Testing Namespace
                {
                    apiVersion: "v1"
                    kind: "Namespace"
                    metadata.name: "solutions-e2e-argocd"
                }
                {
                    apiVersion: "pkg.crossplane.io/v1"
                    kind: "Configuration"
                    metadata.name: "configuration-aws-eks"
                    spec.package: "xpkg.upbound.io/upbound/configuration-aws-eks:v2.0.0"
                }
                {
                    apiVersion: "aws.m.upbound.io/v1beta1"
                    kind: "ProviderConfig"
                    metadata = {
                        name = "upbound-aws-providerconfig"
                        namespace = "solutions-e2e-argocd"
                    }
                    spec.credentials = {
                        source = "Upbound"
                        upbound = {
                            webIdentity = {
                                roleARN = "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                            }
                        }
                    }
                }
                {
                    apiVersion: "aws.platform.upbound.io/v1alpha1"
                    kind: "Network"
                    metadata = {
                        name = "configuration-gitops-argocd-network"
                        namespace = "solutions-e2e-argocd"
                    }
                    spec.parameters = {
                        id: "uptest-gitops-argocd-cluster"
                        providerConfigName: "upbound-aws-providerconfig"
                        region: "us-west-1"
                        vpcCidrBlock: "192.168.0.0/16"
                        subnets: [
                            {
                                availabilityZone: "us-west-1b"
                                type: "public"
                                cidrBlock: "192.168.0.0/18"
                            }
                            {
                                availabilityZone: "us-west-1c"
                                type: "public"
                                cidrBlock: "192.168.64.0/18"
                            }
                            {
                                availabilityZone: "us-west-1b"
                                type: "private"
                                cidrBlock: "192.168.128.0/18"
                            }
                            {
                                availabilityZone: "us-west-1c"
                                type: "private"
                                cidrBlock: "192.168.192.0/18"
                            }
                        ]
                    }
                }
                {
                    apiVersion: "aws.platform.upbound.io/v1alpha1"
                    kind: "EKS"
                    metadata = {
                        name = "configuration-gitops-argocd-cluster"
                        namespace = "solutions-e2e-argocd"
                    }
                    spec = {
                        parameters = {
                            accessConfig = {
                                authenticationMode = "API_AND_CONFIG_MAP"
                                bootstrapClusterCreatorAdminPermissions = True
                            }
                            id = "uptest-gitops-argocd-cluster"
                            providerConfigName = "upbound-aws-providerconfig"
                            nodes = {
                                count = 1
                                instanceType = "t3.small"
                            }
                            region = "us-west-1"
                            version = "1.34"
                        }
                    }
                }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items= _items