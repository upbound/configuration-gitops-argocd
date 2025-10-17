
import models.io.crossplane.helm.v1alpha1 as helmv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1


_items = [
    metav1alpha1.E2ETest{
        metadata.name: "argocd-e2e-test"
        spec= {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                gitopsv1alpha1.XArgo {
                    metadata = {
                        name = "test-argocd-instance"
                    }
                    spec = {
                        parameters = {
                            providerConfigName = "uptest-gitops-argocd-cluster"
                            deletionPolicy = "Delete"
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
                {
                    apiVersion: "pkg.crossplane.io/v1"
                    kind: "Configuration"
                    metadata.name: "configuration-aws-eks"
                    spec.package: "xpkg.upbound.io/upbound/configuration-aws-eks:v0.19.0"
                }
                {
                    apiVersion: "pkg.crossplane.io/v1"
                    kind: "Configuration"
                    metadata.name: "configuration-aws-network"
                    spec.package: "xpkg.upbound.io/upbound/configuration-aws-network:v0.24.0"
                }
                {
                    apiVersion: "aws.upbound.io/v1beta1"
                    kind: "ProviderConfig"
                    metadata.name: "default"
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
                    kind: "XNetwork"
                    metadata.name: "configuration-gitops-argocd-network"
                    spec.parameters = {
                        id: "uptest-gitops-argocd-cluster"
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
                    kind: "XEKS"
                    metadata.name: "configuration-gitops-argocd-cluster"
                    spec = {
                        parameters = {
                            accessConfig = {
                                authenticationMode = "API_AND_CONFIG_MAP"
                                bootstrapClusterCreatorAdminPermissions = True
                            }
                            id = "uptest-gitops-argocd-cluster"
                            nodes = {
                                count = 1
                                instanceType = "t3.small"
                            }
                            region = "us-west-1"
                            version = "1.33"
                        }
                        writeConnectionSecretToRef = {
                            name = "configuration-gitops-argocd-kubeconfig"
                            namespace = "upbound-system"
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