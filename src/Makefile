
SRC_CONFIGS := $(shell find configs -name "*.xml")
SRC_TEMPLATES := $(shell find templates -name "*.xml")

TGT_OE_LAYERSETUP_CONFIGS = $(patsubst configs/%,../configs/%,$(patsubst %.xml,%.txt,$(SRC_CONFIGS)))
TGT_OE_LAYERSETUP_TEMPLATES = $(patsubst templates/%,../sample-files/%,$(patsubst %.xml,%.sample,$(SRC_TEMPLATES)))

TGT_KAS_CONFIGS = $(patsubst configs/%,../kas/%,$(patsubst %.xml,%.yml,$(SRC_CONFIGS)))
TGT_KAS_TEMPLATES = $(patsubst templates/%,../kas/templates/%,$(patsubst %.xml,%.yml,$(SRC_TEMPLATES)))

TMP_BITBAKE_SETUP_FLATTENED_CONFIGS = $(subst /,_,$(patsubst configs/%,%,$(SRC_CONFIGS)))

TGT_BITBAKE_SETUP_CONFIGS = $(patsubst %,../bitbake-setup/%,$(patsubst %.xml,%.conf.json,$(patsubst configs/%,%,$(SRC_CONFIGS))))
TGT_BITBAKE_SETUP_CONFIGS_LOCALCONF = $(patsubst %,../conf/fragments/localconf/configs/%,$(patsubst configs/%.xml,%.conf,$(SRC_CONFIGS)))
TGT_BITBAKE_SETUP_LOCALCONF_TEMPLATES = $(patsubst %,../conf/fragments/localconf/%,$(patsubst templates/%.xml,%,$(filter-out templates/bblayers%,$(SRC_TEMPLATES))))
TARGETS = $(TGT_OE_LAYERSETUP_CONFIGS) \
		  $(TGT_OE_LAYERSETUP_TEMPLATES) \
		  $(TGT_KAS_CONFIGS) \
		  $(TGT_KAS_TEMPLATES) \
		  $(TGT_BITBAKE_SETUP_CONFIGS) \
		  $(TGT_BITBAKE_SETUP_LOCALCONF_TEMPLATES)

all: $(TARGETS)

clean:
	@echo "  CLEAN ../kas"; rm -rf ../kas
	@echo "  CLEAN ../bitbake-setup"; rm -rf ../bitbake-setup
	@echo "  CLEAN ../conf/fragments"; rm -rf ../conf/fragments

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
	@echo "TGT_BITBAKE_SETUP_CONFIGS_LOCALCONF = $(TGT_BITBAKE_SETUP_CONFIGS_LOCALCONF)"
	@echo "TGT_BITBAKE_SETUP_LOCALCONF_TEMPLATES = $(TGT_BITBAKE_SETUP_LOCALCONF_TEMPLATES)"
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
# Bitbake-setup config.conf.json
#------------------------------------------------------------------------------
define xslt_bitbake_setup =
	mkdir -p $(@D); \
	echo "  XLST bitbake-setup $*"; \
	xsltproc --stringparam arConfigName $$loConfigName --xinclude xslt/bitbake-setup.xslt configs/$*.xml > $@; \
	loCheck=`grep local-conf configs/$*.xml`; \
	if [ "$$loCheck" != "" ]; then \
		loDir=`dirname ../conf/fragments/localconf/configs/$*.conf`; \
		mkdir -p $$loDir; \
		echo "  XLST bitbake-setup-config-localconf $*"; \
		xsltproc --stringparam arConfigName $$loConfigName --xinclude xslt/bitbake-setup-config-localconf.xslt configs/$*.xml > ../conf/fragments/localconf/configs/$*.conf; \
	fi
endef

../bitbake-setup/%.conf.json: xslt/bitbake-setup.xslt configs/%.xml
	@loConfigName="$*"; \
	$(xslt_bitbake_setup)

../bitbake-setup/*.conf.json: xslt/bitbake-setup-config-localconf.xslt
../bitbake-setup/*/*.conf.json: xslt/bitbake-setup-config-localconf.xslt

#------------------------------------------------------------------------------
# Bitbake-setup config local-conf
#------------------------------------------------------------------------------
define xslt_bitbake_setup_config_localconf =
	mkdir -p $(@D); \
	echo "  XLST bitbake-setup-config-localconf $*"; \
	xsltproc --stringparam arConfigName $$loConfigName --xinclude $^ > $@; \
	if [ -s $@ ]; then \
		echo "remove empty file: $@"; \
		rm -rf $@; \
	fi
endef

../conf/fragments/localconf/configs/%.conf: xslt/bitbake-setup-config-localconf.xslt configs/%.xml
	@loConfigName="$*"; \
	$(xslt_bitbake_setup_config_localconf)

#------------------------------------------------------------------------------
# Bitbake localconf templates
#------------------------------------------------------------------------------
define bitbake_setup_localconf_templates =
	mkdir -p $(@D); \
	echo "  XLST bitbake-setup-localconf-templates $*"; \
	xsltproc --xinclude $^ > $@
endef

../conf/fragments/localconf/%: xslt/bitbake-setup-localconf-templates.xslt templates/%.xml
	@$(bitbake_setup_localconf_templates)

