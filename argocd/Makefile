# =========================
# Variables
# =========================
ARGOCD_NAMESPACE = argocd
ARGOCD_MANIFEST  = https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
ARGOCD_CM        = argocd-cm.yaml

.PHONY: install status get-password port-forward delete

# =========================
# ArgoCD
# =========================

install:
	@echo "Creating namespace..."
	kubectl create namespace $(ARGOCD_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

	@echo "Installing ArgoCD manifests..."
	kubectl apply -n $(ARGOCD_NAMESPACE) -f $(ARGOCD_MANIFEST)

	@echo "Waiting for ArgoCD controller..."
	kubectl rollout status deployment/argocd-application-controller -n $(ARGOCD_NAMESPACE)

	@echo "Applying ArgoCD config (argocd-cm)..."
	kubectl apply -f $(ARGOCD_CM)

	@echo "Restarting ArgoCD controller to reload config..."
	kubectl rollout restart deployment/argocd-application-controller -n $(ARGOCD_NAMESPACE)

status:
	kubectl get all -n $(ARGOCD_NAMESPACE)

get-password:
	@echo "ArgoCD admin password:"
	kubectl get secret argocd-initial-admin-secret \
	  -n $(ARGOCD_NAMESPACE) \
	  -o jsonpath="{.data.password}" | base64 --decode ; echo

port-forward:
	@echo "ArgoCD UI available at http://localhost:8085"
	kubectl port-forward svc/argocd-server \
	  -n $(ARGOCD_NAMESPACE) 8085:443

delete:
	@echo "🗑 Removing ArgoCD..."
	kubectl delete namespace $(ARGOCD_NAMESPACE)
