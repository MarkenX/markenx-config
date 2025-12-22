# =========================
# Variables
# =========================
K8S_DIR = k8s/base
APP_NAME = markenx-api

# =========================
# Targets
# =========================

.PHONY: deploy delete status logs restart

deploy:
	kubectl apply -k $(K8S_DIR)

delete:
	kubectl delete -k $(K8S_DIR)

status:
	kubectl get all

logs:
	kubectl logs -f deploy/$(APP_NAME)

restart:
	kubectl rollout restart deploy/$(APP_NAME)
