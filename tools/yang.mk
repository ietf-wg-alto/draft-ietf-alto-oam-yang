YANGDIR ?= yang

STDYANGDIR ?= tools/yang
$(STDYANGDIR):
	git clone --depth 10 -b main https://github.com/YangModels/yang $@

LIBYANGBIN ?= yanglint

OPTIONS=--tree-print-groupings --tree-no-expand-uses -f tree --tree-line-length=67
ifeq ($(OS), Windows_NT)
YANG_PATH="$(YANGDIR);$(STDYANGDIR)/standard/ietf/RFC/;$(STDYANGDIR)/experimental/ietf-extracted-YANG-modules"
else
YANG_PATH="$(YANGDIR):$(STDYANGDIR)/standard/ietf/RFC/:$(STDYANGDIR)/experimental/ietf-extracted-YANG-modules"
endif
YANG=$(wildcard $(YANGDIR)/*.yang)
STDYANG=$(wildcard $(YANGDIR)/ietf-*.yang)
EXPYANG=$(wildcard $(YANGDIR)/example-*.yang)
EXPJSON=$(wildcard $(YANGDIR)/example-*.json)
TXT=$(patsubst $(YANGDIR)/%.yang,%-diagram.txt,$(YANG))
YANGLINT=$(patsubst $(YANGDIR)/ietf-%.yang,yang-lint-%.log,$(STDYANG))

# Draft file for YANG Catalog validation
# The draft must be generated first using 'make' or 'make draft'
DRAFT_TXT ?= draft-ietf-alto-oam-yang.txt

.PHONY: yang-lint yang-gen-diagram yang-clean yang-catalog-validate

pyang-lint: $(STDYANG) $(EXPYANG) $(STDYANGDIR)
	pyang -V --ietf -p $(YANG_PATH) $(STDYANG)
	pyang -V -p $(YANG_PATH) $(EXPYANG)

# Validation using YANG Catalog REST API
# This uploads the draft and validates embedded YANG modules using xym extraction
yang-catalog-validate: $(DRAFT_TXT)
	@echo "Validating YANG modules using YANG Catalog API..."
	@echo "This uploads the draft and extracts YANG modules using xym"
	@echo ""
	@./tools/yang-validator-api.sh $(DRAFT_TXT)

yang-lint-%.log: $(YANGDIR)/ietf-%.yang
	$(LIBYANGBIN) --verbose -p $(YANGDIR)/temp -p $(YANGDIR) -p $(STDYANGDIR)/standard/ietf/RFC/ -p $(STDYANGDIR)/experimental/ietf-extracted-YANG-modules $< -i -o $@

yang-lint: $(YANGLINT)

yang-gen-diagram: yang-lint $(TXT)

yang-clean:
	rm -f $(TXT) $(YANGLINT)

yangson-validate: $(EXPJSON) $(STDYANGDIR)
	yangson -p $(YANGDIR) -p $(YANGDIR):$(STDYANGDIR)/standard/ietf/RFC/:$(STDYANGDIR)/experimental/ietf-extracted-YANG-modules -v $(EXPJSON) $(YANGDIR)/yang-library-ietf-alto.json

%-diagram.txt: $(YANGDIR)/%.yang
	pyang $(OPTIONS) -p $(YANG_PATH) $< > $@
