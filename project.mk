PROJECT_NAME := configuration-gitops-argocd
UPTEST_INPUT_MANIFESTS := examples/argocd-xr.yaml
UPTEST_SKIP_UPDATE := true
XPKG_IGNORE ?= .github/workflows/*.yaml,.github/workflows/*.yml,examples/*.yaml,.work/uptest-datasource.yaml,.cache/render/*,test/provider/*,gitops/*
