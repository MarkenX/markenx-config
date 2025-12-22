# =========================
# Variables
# =========================
ARGOCD_NAMESPACE = argocd
ARGOCD_MANIFEST  = https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# =========================
# Phony targets
# =========================
.PHONY: argocd-install argocd-status argocd-password argocd-port-forward argocd-delete

# =========================
# ArgoCD
# =========================

argocd-install:
	@echo "Installing ArgoCD..."
	kubectl create namespace $(ARGOCD_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n $(ARGOCD_NAMESPACE) -f $(ARGOCD_MANIFEST)
	@echo "Waiting for ArgoCD to be ready..."
	kubectl rollout status deployment/argocd-server -n $(ARGOCD_NAMESPACE)

argocd-status:
	kubectl get all -n $(ARGOCD_NAMESPACE)

argocd-password:
	@echo "ArgoCD admin password:"
	kubectl get secret argocd-initial-admin-secret \
	  -n $(ARGOCD_NAMESPACE) \
	  -o jsonpath="{.data.password}" | base64 --decode ; echo

argocd-port-forward:
	@echo "ArgoCD UI available at http://localhost:8080"
	kubectl port-forward svc/argocd-server \
	  -n $(ARGOCD_NAMESPACE) 8080:443

argocd-delete:
	@echo "🗑 Removing ArgoCD..."
	kubectl delete namespace $(ARGOCD_NAMESPACE)
