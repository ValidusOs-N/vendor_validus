PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/bin/sysinit:system/bin/sysinit \
    vendor/validus/prebuilt/etc/init.validus.rc:root/init.validus.rc

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    dalvik.vm.debug.alloc=0 \
    ro.config.alarm_alert=Oxygen.ogg \
    ro.config.ringtone=Orion.ogg \
    ro.config.notification_sound=Tethys.ogg \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.build.selinux=1 \
    ro.com.android.dataroaming=false

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/validus/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/validus/prebuilt/common/bin/50-base.sh:system/addon.d/50-base.sh \

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/validus/config/permissions/backup.xml:system/etc/sysconfig/backup.xml

# Init file
PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/common/etc/init.local.rc:root/init.du.rc

# Copy latinime for gesture typing
PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/common/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so

# SELinux filesystem labels
PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/common/etc/init.d/50selinuxrelabel:system/etc/init.d/50selinuxrelabel

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/common/etc/mkshrc:system/etc/mkshrc \

PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/validus/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit \
    vendor/validus/prebuilt/common/bin/sysinit:system/bin/sysinit

# Stagefright FFMPEG plugin
ifneq ($(BOARD_USES_QCOM_HARDWARE),true)
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so
endif

# Packages
include vendor/validus/config/packages.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/validus/overlay/common

# Boot animation include
ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/validus/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
else
PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif
endif

# SuperSU
PRODUCT_COPY_FILES += \
    vendor/validus/prebuilt/common/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
    vendor/validus/prebuilt/common/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

# Versioning System
ANDROID_VERSION = 7.0
VALIDUS_VERSION = v10.0
ifndef VALIDUS_BUILD_TYPE
    VALIDUS_BUILD_TYPE := WOLVESBAYNE
    PLATFORM_VERSION_CODENAME := WOLVESBAYNE
endif

#Build VALIDUS-Updater only if VALIDUS_BUILD_TYPE isn't WOLVESBAYNE
#ifneq ($(VALIDUS_BUILD_TYPE),WOLVESBAYNE)
#PRODUCT_PACKAGES += \
#    VALIDUS-Updater
#endif

# easy way to extend to add more packages
-include vendor/extra/product.mk

# Set all versions
VALIDUS_VERSION := VALIDUS_$(VALIDUS_BUILD)_$(ANDROID_VERSION)_$(shell date -u +%Y%m%d-%H%M).$(VALIDUS_VERSION)-$(VALIDUS_BUILD_TYPE)
VALIDUS_MOD_VERSION := VALIDUS_$(VALIDUS_BUILD)_$(ANDROID_VERSION)_$(shell date -u +%Y%m%d-%H%M).$(VALIDUS_VERSION)-$(VALIDUS_BUILD_TYPE)

PRODUCT_PROPERTY_OVERRIDES += \
    BUILD_DISPLAY_ID=$(BUILD_ID) \
    ro.validus.version=$(VALIDUS_VERSION) \
    ro.mod.version=$(VALIDUS_BUILD_TYPE)-v10.0

