.PHONY: argocd deploy

argocd:
	$(MAKE) -C argocd install

deploy:
	$(MAKE) -C k8s deploy
