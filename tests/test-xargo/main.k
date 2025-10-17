import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "test-xargo"
        spec = {
            assertResources: [
                gitopsv1alpha1.XArgo{
                    metadata = {
                        name = "configuration-gitops-argocd"
                    }
                    spec = {
                        parameters = {
                            providerConfigName = "configuration-gitops-argocd"
                            deletionPolicy = "Delete"
                            operators = {
                                argocd = {
                                    version = "7.1.1"
                                }
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
                helmv1beta1.Release{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "configuration-gitops-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "releaseArgo"
                            "crossplane.io/external-name" = "argocd"
                        }
                    }
                    spec = {
                        deletionPolicy = "Delete"
                        providerConfigRef = {
                            name = "configuration-gitops-argocd"
                        }
                        forProvider = {
                            namespace = "argocd"
                            chart = {
                                name = "argo-cd"
                                repository = "https://argoproj.github.io/argo-helm"
                                version = "7.1.1"
                            }
                            values = {
                                applicationSet = {
                                    metrics = {
                                        enabled = True
                                        service = {
                                            annotations = {
                                                "prometheus.io/scrape" = "true"
                                            }
                                        }
                                    }
                                    replicaCount = 1
                                }
                                configs = {
                                    cm = {
                                        "resource.respectRBAC" = "normal"
                                        "application.resourceTrackingMethod" = "annotation"
                                    }
                                    params = {
                                        "application.namespaces" = "cluster-*"
                                    }
                                }
                                controller = {
                                    replicas = 1
                                }
                                dex = {
                                    enabled = False
                                }
                                "redis-ha" = {
                                    enabled = True
                                }
                            }
                        }
                    }
                }
                kubernetesv1alpha2.Object{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "configuration-gitops-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "argoApplicationSet"
                        }
                    }
                    spec = {
                        deletionPolicy = "Delete"
                        providerConfigRef = {
                            name = "configuration-gitops-argocd"
                        }
                        forProvider = {
                            manifest = {
                                apiVersion = "argoproj.io/v1alpha1"
                                kind = "ApplicationSet"
                                metadata = {
                                    namespace = "argocd"
                                    name = "configuration-gitops-argocd"
                                }
                                spec = {
                                    generators = [
                                        {
                                            matrix = {
                                                generators = [
                                                    {
                                                        git = {
                                                            repoURL = "https://github.com/upbound/configuration-gitops-argocd.git"
                                                            revision = "HEAD"
                                                            files = [
                                                                {path = "gitops"}
                                                            ]
                                                        }
                                                    }
                                                    {
                                                        list = {
                                                            elements = []
                                                            elementsYaml = "{{ .key.components | toJson }}"
                                                        }
                                                    }
                                                ]
                                            }
                                        }
                                    ]
                                    goTemplate = True
                                    goTemplateOptions = ["missingkey=error"]
                                    template = {
                                        metadata = {
                                            name = "{{.name}}"
                                        }
                                        spec = {
                                            destination = {
                                                namespace = "{{.namespace}}"
                                                server = "{{.server}}"
                                            }
                                            project = "{{.project}}"
                                            source = {
                                                repoURL = "{{.repoUrl}}"
                                                targetRevision = "{{.version}}"
                                                path = "{{.folder}}"
                                            }
                                            syncPolicy = {
                                                automated = {
                                                    selfHeal = True
                                                }
                                                syncOptions = ["CreateNamespace=true"]
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            ]
            compositionPath: "apis/composition.yaml"
            xrPath: "examples/argocd-xr.yaml"
            xrdPath: "apis/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items = _items
