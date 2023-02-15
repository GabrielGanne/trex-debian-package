PREFIX ?= /opt/
DESTDIR =

TREX_RELEASE = v2.99
TREX_PATH = t-rex
TREX_PYTHONPATH ?= $(TREX_PATH)/$(TREX_RELEASE)/automation/trex_control_plane/interactive
TREX_SETUP_DONE = trex-stamp
$(TREX_SETUP_DONE):
	@rm -rf $(TREX_PATH)
	@mkdir -p $(TREX_PATH)
	@cd $(TREX_PATH) && \
		wget --no-check-certificate https://trex-tgn.cisco.com/trex/release/$(TREX_RELEASE).tar.gz && \
		tar xf $(TREX_RELEASE).tar.gz
	# remove non-x86 arch files
	find $(TREX_PATH) -type d -name ppc64le -exec rm -rf {} +
	find $(TREX_PATH) -type d -name ppc -exec rm -rf {} +
	find $(TREX_PATH) -type d -name arm -exec rm -rf {} +
	@touch $@

# alias target for convenence
.PHONY: trex-setup
trex-setup: $(TREX_SETUP_DONE)

.PHONY: clean
clean:
	@rm -vf trex-stamp
	@rm -rvf $(TREX_SETUP_DONE)

$(DESTDIR)/$(PREFIX)/trex: $(TREX_SETUP_DONE)
	@mkdir -p $(DESTDIR)/$(PREFIX)
	@cp -rvu $(TREX_PATH)/$(TREX_RELEASE) $(DESTDIR)/$(PREFIX)/trex-$(TREX_RELEASE)
	@ln -v -s $(DESTDIR)/$(PREFIX)/trex-$(TREX_RELEASE) $(DESTDIR)/$(PREFIX)/trex

.PHONY: install
install: $(DESTDIR)/$(PREFIX)/trex

.PHONY: uninstall
uninstall:
	unlink $(DESTDIR)/$(PREFIX)/trex
	@rm -rvf $(DESTDIR)/$(PREFIX)/trex-$(TREX_RELEASE)

trex-$(TREX_RELEASE).tar.xz:
	git archive HEAD --output $@

.PHONY: dist
dist: trex-$(TREX_RELEASE).tar.xz