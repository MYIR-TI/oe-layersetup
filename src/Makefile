
SRC_CONFIGS := $(shell find configs -name "*.xml")
SRC_TEMPLATES := $(shell find templates -name "*.xml")

TGT_OE_LAYERSETUP_CONFIGS = $(patsubst configs/%,../configs/%,$(patsubst %.xml,%.txt,$(SRC_CONFIGS)))
TGT_OE_LAYERSETUP_TEMPLATES = $(patsubst templates/%,../sample-files/%,$(patsubst %.xml,%.sample,$(SRC_TEMPLATES)))

TGT_KAS_CONFIGS = $(patsubst configs/%,../kas/%,$(patsubst %.xml,%.yml,$(SRC_CONFIGS)))
TGT_KAS_TEMPLATES = $(patsubst templates/%,../kas/templates/%,$(patsubst %.xml,%.yml,$(SRC_TEMPLATES)))

TMP_BITBAKE_SETUP_FLATTENED_CONFIGS = $(subst /,_,$(patsubst configs/%,%,$(SRC_CONFIGS)))

TGT_BITBAKE_SETUP_CONFIGS = $(patsubst %,../bitbake-setup/%,$(patsubst %.xml,%.json,$(TMP_BITBAKE_SETUP_FLATTENED_CONFIGS)))
TGT_BITBAKE_SETUP_TEMPLATES_BBLAYERS_CONF = $(patsubst %,../conf/templates/%,$(patsubst %.xml,%/bblayers.conf.sample,$(TMP_BITBAKE_SETUP_FLATTENED_CONFIGS)))
TGT_BITBAKE_SETUP_TEMPLATES_CONF_NOTES = $(patsubst %,../conf/templates/%,$(patsubst %.xml,%/conf-notes.txt,$(TMP_BITBAKE_SETUP_FLATTENED_CONFIGS)))
TGT_BITBAKE_SETUP_TEMPLATES_CONF_SUMMARY = $(patsubst %,../conf/templates/%,$(patsubst %.xml,%/conf-summary.txt,$(TMP_BITBAKE_SETUP_FLATTENED_CONFIGS)))
TGT_BITBAKE_SETUP_TEMPLATES_LOCAL_CONF = $(patsubst %,../conf/templates/%,$(patsubst %.xml,%/local.conf.sample,$(TMP_BITBAKE_SETUP_FLATTENED_CONFIGS)))
TGT_BITBAKE_SETUP_TEMPLATES = $(TGT_BITBAKE_SETUP_TEMPLATES_BBLAYERS_CONF) \
							  $(TGT_BITBAKE_SETUP_TEMPLATES_CONF_NOTES) \
							  $(TGT_BITBAKE_SETUP_TEMPLATES_CONF_SUMMARY) \
							  $(TGT_BITBAKE_SETUP_TEMPLATES_LOCAL_CONF)

TARGETS = $(TGT_OE_LAYERSETUP_CONFIGS) \
		  $(TGT_OE_LAYERSETUP_TEMPLATES) \
		  $(TGT_KAS_CONFIGS) \
		  $(TGT_KAS_TEMPLATES) \
		  $(TGT_BITBAKE_SETUP_CONFIGS) \
		  $(TGT_BITBAKE_SETUP_TEMPLATES)

all: $(TARGETS)

clean:
	@echo "  CLEAN ../kas"; rm -rf ../kas
	@echo "  CLEAN ../bitbake-setup"; rm -rf ../bitbake-setup
	@echo "  CLEAN ../conf/templates"; rm -rf ../conf/templates

vars:
	@echo "Source"
	@echo "-------------------------"
	@echo "SRC_CONFIGS = $(SRC_CONFIGS)"
	@echo "SRC_TEMPLATES = $(SRC_TEMPLATES)"
	@echo ""
	@echo "oe-layersetup"
	@echo "-------------------------"
	@echo "TGT_OE_LAYERSETUP_CONFIGS = $(TGT_OE_LAYERSETUP_CONFIGS)"
	@echo "TGT_OE_LAYERSETUP_TEMPLATES = $(TGT_OE_LAYERSETUP_TEMPLATES)"
	@echo ""
	@echo "kas"
	@echo "-------------------------"
	@echo "TGT_KAS_CONFIGS = $(TGT_KAS_CONFIGS)"
	@echo "TGT_KAS_TEMPLATES = $(TGT_KAS_TEMPLATES)"
	@echo ""
	@echo "bitbake-setup"
	@echo "-------------------------"
	@echo "TGT_BITBAKE_SETUP_CONFIGS = $(TGT_BITBAKE_SETUP_CONFIGS)"
	@echo "TGT_BITBAKE_SETUP_TEMPLATES = $(TGT_BITBAKE_SETUP_TEMPLATES)"
	@echo ""
	@echo "Targets"
	@echo "-------------------------"
	@echo "TARGETS = $(TARGETS)"

#------------------------------------------------------------------------------
# OE-LayerSetup
#------------------------------------------------------------------------------
define xslt_oe_layersetup =
	mkdir -p $(@D); \
	echo "  XLST oe-layersetup $*"; \
	xsltproc --xinclude $^ > $@
endef

define xslt_oe_layersetup_templates =
	mkdir -p $(@D); \
	echo "  XLST oe-layersetup-templates $*"; \
	xsltproc --xinclude $^ > $@
endef

../configs/%.txt: xslt/oe-layersetup.xslt configs/%.xml
	@$(xslt_oe_layersetup)

../sample-files/%.sample: xslt/oe-layersetup-templates.xslt templates/%.xml
	@$(xslt_oe_layersetup_templates)

#------------------------------------------------------------------------------
# KAS
#------------------------------------------------------------------------------
define xslt_kas =
	mkdir -p $(@D); \
	echo "  XLST kas $*"; \
	xsltproc --stringparam arTemplatePrefix $$loTemplatePrefix --xinclude $^ > $@
endef

define xslt_kas_templates =
	mkdir -p $(@D); \
	echo "  XLST kas-templates $*"; \
	xsltproc --stringparam arTemplatePrefix $$loTemplatePrefix --xinclude $^ > $@
endef

../kas/%.yml: xslt/kas.xslt configs/%.xml
	@loTemplatePrefix1=`realpath --relative-to configs/$*.xml .`; \
	loTemplatePrefix2=`dirname $${loTemplatePrefix1}`; \
	loTemplatePrefix=`dirname $${loTemplatePrefix2}`; \
	$(xslt_kas)

../kas/templates/%.yml: xslt/kas-templates.xslt templates/%.xml
	@$(xslt_kas_templates)

#------------------------------------------------------------------------------
# Bitbake-setup config.json
#------------------------------------------------------------------------------
define xslt_bitbake_setup =
	mkdir -p $(@D); \
	echo "  XLST bitbake-setup $*"; \
	xsltproc --stringparam arConfigName $$loConfigName --xinclude $^ > $@
endef

../bitbake-setup/%.json: xslt/bitbake-setup.xslt configs/%.xml
	@loConfigName="$*"; \
	$(xslt_bitbake_setup)

../bitbake-setup/amsdk_%.json: xslt/bitbake-setup.xslt configs/amsdk/%.xml
	@loConfigName="amsdk_$*"; \
	$(xslt_bitbake_setup)

../bitbake-setup/coresdk_%.json: xslt/bitbake-setup.xslt configs/coresdk/%.xml
	@loConfigName="coresdk_$*"; \
	$(xslt_bitbake_setup)

../bitbake-setup/glsdk_%.json: xslt/bitbake-setup.xslt configs/glsdk/%.xml
	@loConfigName="glsdk_$*"; \
	$(xslt_bitbake_setup)

../bitbake-setup/mcsdk_%.json: xslt/bitbake-setup.xslt configs/mcsdk/%.xml
	@loConfigName="mcsdk_$*"; \
	$(xslt_bitbake_setup)

../bitbake-setup/processor-sdk_%.json: xslt/bitbake-setup.xslt configs/processor-sdk/%.xml
	@loConfigName="processor-sdk_$*"; \
	$(xslt_bitbake_setup)

../bitbake-setup/processor-sdk-analytics_%.json: xslt/bitbake-setup.xslt configs/processor-sdk-analytics/%.xml
	@loConfigName="processor-sdk-analytics_$*"; \
	$(xslt_bitbake_setup)

../bitbake-setup/processor-sdk-linux_%.json: xslt/bitbake-setup.xslt configs/processor-sdk-linux/%.xml
	@loConfigName="processor-sdk-linux_$*"; \
	$(xslt_bitbake_setup)

#------------------------------------------------------------------------------
# Bitbake-setup templates
#------------------------------------------------------------------------------
define xslt_bitbake_setup_templates =
	mkdir -p $(@D); \
	echo "  XLST bitbake-setup-templates $*"; \
	xsltproc --stringparam arConfigName $$loConfigName --xinclude $^ > $@
endef

../conf/templates/%/bblayers.conf.sample: xslt/bitbake-setup-bblayers-conf.xslt configs/%.xml
	@loConfigName="$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/amsdk_%/bblayers.conf.sample: xslt/bitbake-setup-bblayers-conf.xslt configs/amsdk/%.xml
	@loConfigName="amsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/coresdk_%/bblayers.conf.sample: xslt/bitbake-setup-bblayers-conf.xslt configs/coresdk/%.xml
	@loConfigName="coresdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/glsdk_%/bblayers.conf.sample: xslt/bitbake-setup-bblayers-conf.xslt configs/glsdk/%.xml
	@loConfigName="glsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/mcsdk_%/bblayers.conf.sample: xslt/bitbake-setup-bblayers-conf.xslt configs/mcsdk/%.xml
	@loConfigName="mcsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk_%/bblayers.conf.sample: xslt/bitbake-setup-bblayers-conf.xslt configs/processor-sdk/%.xml
	@loConfigName="processor-sdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk-analytics_%/bblayers.conf.sample: xslt/bitbake-setup-bblayers-conf.xslt configs/processor-sdk-analytics/%.xml
	@loConfigName="processor-sdk-analytics_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk-linux_%/bblayers.conf.sample: xslt/bitbake-setup-bblayers-conf.xslt configs/processor-sdk-linux/%.xml
	@loConfigName="processor-sdk-linux_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/%/conf-notes.txt: xslt/bitbake-setup-conf-notes.xslt configs/%.xml
	@loConfigName="$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/amsdk_%/conf-notes.txt: xslt/bitbake-setup-conf-notes.xslt configs/amsdk/%.xml
	@loConfigName="amsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/coresdk_%/conf-notes.txt: xslt/bitbake-setup-conf-notes.xslt configs/coresdk/%.xml
	@loConfigName="coresdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/glsdk_%/conf-notes.txt: xslt/bitbake-setup-conf-notes.xslt configs/glsdk/%.xml
	@loConfigName="glsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/mcsdk_%/conf-notes.txt: xslt/bitbake-setup-conf-notes.xslt configs/mcsdk/%.xml
	@loConfigName="mcsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk_%/conf-notes.txt: xslt/bitbake-setup-conf-notes.xslt configs/processor-sdk/%.xml
	@loConfigName="processor-sdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk-analytics_%/conf-notes.txt: xslt/bitbake-setup-conf-notes.xslt configs/processor-sdk-analytics/%.xml
	@loConfigName="processor-sdk-analytics_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk-linux_%/conf-notes.txt: xslt/bitbake-setup-conf-notes.xslt configs/processor-sdk-linux/%.xml
	@loConfigName="processor-sdk-linux_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/%/conf-summary.txt: xslt/bitbake-setup-conf-summary.xslt configs/%.xml
	@loConfigName="$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/amsdk_%/conf-summary.txt: xslt/bitbake-setup-conf-summary.xslt configs/amsdk/%.xml
	@loConfigName="amsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/coresdk_%/conf-summary.txt: xslt/bitbake-setup-conf-summary.xslt configs/coresdk/%.xml
	@loConfigName="coresdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/glsdk_%/conf-summary.txt: xslt/bitbake-setup-conf-summary.xslt configs/glsdk/%.xml
	@loConfigName="glsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/mcsdk_%/conf-summary.txt: xslt/bitbake-setup-conf-summary.xslt configs/mcsdk/%.xml
	@loConfigName="mcsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk_%/conf-summary.txt: xslt/bitbake-setup-conf-summary.xslt configs/processor-sdk/%.xml
	@loConfigName="processor-sdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk-analytics_%/conf-summary.txt: xslt/bitbake-setup-conf-summary.xslt configs/processor-sdk-analytics/%.xml
	@loConfigName="processor-sdk-analytics_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk-linux_%/conf-summary.txt: xslt/bitbake-setup-conf-summary.xslt configs/processor-sdk-linux/%.xml
	@loConfigName="processor-sdk-linux_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/%/local.conf.sample: xslt/bitbake-setup-local-conf.xslt configs/%.xml
	@loConfigName="$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/amsdk_%/local.conf.sample: xslt/bitbake-setup-local-conf.xslt configs/amsdk/%.xml
	@loConfigName="amsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/coresdk_%/local.conf.sample: xslt/bitbake-setup-local-conf.xslt configs/coresdk/%.xml
	@loConfigName="coresdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/glsdk_%/local.conf.sample: xslt/bitbake-setup-local-conf.xslt configs/glsdk/%.xml
	@loConfigName="glsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/mcsdk_%/local.conf.sample: xslt/bitbake-setup-local-conf.xslt configs/mcsdk/%.xml
	@loConfigName="mcsdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk_%/local.conf.sample: xslt/bitbake-setup-local-conf.xslt configs/processor-sdk/%.xml
	@loConfigName="processor-sdk_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk-analytics_%/local.conf.sample: xslt/bitbake-setup-local-conf.xslt configs/processor-sdk-analytics/%.xml
	@loConfigName="processor-sdk-analytics_$*"; \
	$(xslt_bitbake_setup_templates)

../conf/templates/processor-sdk-linux_%/local.conf.sample: xslt/bitbake-setup-local-conf.xslt configs/processor-sdk-linux/%.xml
	@loConfigName="processor-sdk-linux_$*"; \
	$(xslt_bitbake_setup_templates)

