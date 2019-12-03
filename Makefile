SHELL := /bin/bash
GO := GO15VENDOREXPERIMENT=1 go
NAME := jx-app-fossa
OS := $(shell uname)
MAIN_GO := main.go
ROOT_PACKAGE := $(GIT_PROVIDER)/$(ORG)/$(NAME)
GO_VERSION := $(shell $(GO) version | sed -e 's/^[^0-9.]*\([0-9.]*\).*/\1/')
PACKAGE_DIRS := $(shell $(GO) list ./... | grep -v /vendor/)
PKGS := $(shell go list ./... | grep -v /vendor | grep -v generated)
PKGS := $(subst  :,_,$(PKGS))
BUILDFLAGS := ''
CGO_ENABLED = 0
VENDOR_DIR=vendor

all: build

check: fmt build test

.PHONY: build
build:
	CGO_ENABLED=$(CGO_ENABLED) $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME) $(MAIN_GO)

test: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) test $(PACKAGE_DIRS) -test.v

full: $(PKGS)

install:
	GOBIN=${GOPATH}/bin $(GO) install -ldflags $(BUILDFLAGS) $(MAIN_GO)

fmt:
	@FORMATTED=`$(GO) fmt $(PACKAGE_DIRS)`
	@([[ ! -z "$(FORMATTED)" ]] && printf "Fixed unformatted files:\n$(FORMATTED)") || true

clean:
	rm -rf build release

linux:
	CGO_ENABLED=$(CGO_ENABLED) GOOS=linux GOARCH=amd64 $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME) $(MAIN_GO)

.PHONY: release clean

FGT := $(GOPATH)/bin/fgt
$(FGT):
	go get github.com/GeertJohan/fgt

GOLINT := $(GOPATH)/bin/golint
$(GOLINT):
	go get github.com/golang/lint/golint

$(PKGS): $(GOLINT) $(FGT)
	@echo "LINTING"
	@$(FGT) $(GOLINT) $(GOPATH)/src/$@/*.go
	@echo "VETTING"
	@go vet -v $@
	@echo "TESTING"
	@go test -v $@

.PHONY: lint
lint: vendor | $(PKGS) $(GOLINT) # ❷
	@cd $(BASE) && ret=0 && for pkg in $(PKGS); do \
	    test -z "$$($(GOLINT) $$pkg | tee /dev/stderr)" || ret=1 ; \
	done ; exit $$ret

watch:
	reflex -r "\.go$" -R "vendor.*" make skaffold-run

skaffold-run: build
	skaffold run -p dev

.PHONY: release
release: update-release-version skaffold-build detach-and-release ## Creates a release
	cd charts/jx-app-fossa && jx step helm release
	jx step changelog --version v$(VERSION) -p $$(git merge-base $$(git for-each-ref --sort=-creatordate --format='%(objectname)' refs/tags | sed -n 2p) master) -r $$(git merge-base $$(git for-each-ref --sort=-creatordate --format='%(objectname)' refs/tags | sed -n 1p) master)

.PHONY: update-release-version
update-release-version: ## Updates the release version
ifeq ($(OS),darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" ./charts/jx-app-fossa/Chart.yaml
	sed -i "" -e "s/tag: .*/tag: $(VERSION)/" ./charts/jx-app-fossa/values.yaml
else ifeq ($(OS),linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" ./charts/jx-app-fossa/Chart.yaml
	sed -i -e "s/tag: .*/tag: $(VERSION)/" ./charts/jx-app-fossa/values.yaml
else
	echo "platform $(OS) not supported to tag with"
	exit -1
endif

.PHONY: detach-and-release
detach-and-release:  ## Gets into detached HEAD mode and  pushes release
	git checkout $(shell git rev-parse HEAD)
	git add --all
	git commit -m "release $(VERSION)" --allow-empty # if first release then no version update is performed
	git tag -fa v$(VERSION) -m "Release version $(VERSION)"
	git push origin HEAD v$(VERSION)