# =========================
# Variables
# =========================
K8S_DIR = base
APP_NAME = markenx-api

# =========================
# Targets
# =========================

.PHONY: deploy delete status logs restart deploy-crds deploy-resources

deploy: deploy-crds deploy-resources

deploy-crds:
	@echo "Applying CRDs first..."
	kubectl apply -k $(K8S_DIR)/keycloak --selector=apiextensions.k8s.io/v1=CustomResourceDefinition || \
	kubectl apply -f $(K8S_DIR)/keycloak/crd-keycloaks.yaml -f $(K8S_DIR)/keycloak/crd-keycloakrealmimports.yaml
	@echo "Waiting for CRDs to be established..."
	kubectl wait --for condition=established --timeout=60s crd/keycloaks.k8s.keycloak.org || true
	kubectl wait --for condition=established --timeout=60s crd/keycloakrealmimports.k8s.keycloak.org || true
	@echo "CRDs are ready!"

deploy-resources:
	@echo "Applying all resources..."
	kubectl apply -k $(K8S_DIR)

delete:
	kubectl delete -k $(K8S_DIR)

status:
	kubectl get all -n markenx

logs:
	kubectl logs -f deploy/$(APP_NAME) -n markenx

restart:
	kubectl rollout restart deploy/$(APP_NAME) -n markenx
