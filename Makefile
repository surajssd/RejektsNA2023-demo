.PHONY: deploy-aks
deploy-aks:
	./infra/deploy-aks.sh

.PHONY: deploy-kbs
deploy-kbs:
	./kbs/deploy-kbs.sh

.PHONY: deploy-caa
deploy-caa:
	./infra/deploy-caa.sh

.PHONY: encrypt-model-and-upload
encrypt-model-and-upload:
	./app/encrypt-and-upload.sh

.PHONY: deploy-triton-server
deploy-triton-server:
	./app/deploy-triton.sh

.PHONY: download-triton-client
download-triton-client:
	git clone https://github.com/triton-inference-server/client python-triton-client

.PHONY: clean-kbs
clean-kbs:
	rm -rf kbs/kbs

.PHONY: clean-caa
clean-caa:
	rm -rf infra/cloud-api-adaptor

.PHONY: clean-app-data
clean-app-data:
	rm -rf python-triton-client
	rm key.bin
	rm app/models.tar.gz.enc

.PHONY: clean
clean: clean-kbs clean-caa clean-app-data

