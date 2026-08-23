.DEFAULT_GOAL := help
.PHONY: help setup check-host build start stop restart logs shell course verify clean

help:
	@awk 'BEGIN {FS = ":.*## "; printf "Oncology sequencing workbench\n\n"} /^[a-zA-Z_-]+:.*## / {printf "  %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Create .env, host directories, and a random Jupyter token
	./scripts/setup.sh

check-host: ## Check Docker, Compose, NVIDIA driver, and GPU passthrough
	./scripts/check-host.sh

build: ## Build the pinned Bioconductor/Python/GPU image
	docker compose build

start: ## Start JupyterLab and open it in the Ubuntu desktop browser
	./scripts/start.sh

stop: ## Stop the workbench without deleting notebooks or data
	docker compose down

restart: ## Restart JupyterLab
	docker compose restart workbench

logs: ## Follow JupyterLab logs
	docker compose logs --follow --tail=200 workbench

shell: ## Open a shell inside the running workbench
	docker compose exec workbench bash

course: ## Download/update official course notebooks, slides, and provided data
	docker compose exec workbench /opt/workbench/scripts/fetch-course-materials.sh

verify: ## Verify both kernels, R↔Python bridges, genomics tools, and GPU access
	docker compose exec workbench /opt/workbench/scripts/verify-stack.sh

clean: ## Remove only the container and image; mounted work and data are preserved
	docker compose down --rmi local
