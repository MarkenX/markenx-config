# =========================
# Variables
# =========================
K8S_DIR = base/argocd
APP_NAME = markenx-api

# =========================
# Targets
# =========================

.PHONY: deploy delete status logs restart deploy-crds deploy-resources

deploy:
	kubectl apply -k $(K8S_DIR)

delete:
	kubectl delete -k $(K8S_DIR)

status:
	kubectl get all -n markenx

logs:
	kubectl logs -f deploy/$(APP_NAME) -n markenx

restart:
	kubectl rollout restart deploy/$(APP_NAME) -n markenx
