.PHONY: argocd deploy

argocd:
	$(MAKE) -C argocd argocd-install

deploy:
	$(MAKE) -C k8s deploy
