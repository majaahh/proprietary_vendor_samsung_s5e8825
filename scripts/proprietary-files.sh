#!/usr/bin/env bash
set -e
propfile="../../proprietary-files/proprietary.${MODEL}_${CSC}_${OMC}"
audio_blobs=( "APDV_AUDIO_SLSI.bin" "AP_AUDIO_SLSI.bin" "calliope_sram.bin" "vts.bin" )
fw_blobs=( "NPU.bin" "mfc_fw.bin" "os.checked.bin" )
grep -q "SC-53C" "vendor/build.prop" && fw_blobs+=( "nfc/libsn100u_fw.so" )
grep -q "m34" "vendor/build.prop" && audio_blobs=( "calliope_sram.bin" "vts.bin" )

cd vendor/firmware

[[ -f "$propfile" ]] && rm -f "$propfile"

append_section_first() {
    local title="$1"
    shift
    echo -e "# $title - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "$propfile"
    for b in "$@"; do
        if find -type f -name "$b" -print -quit | grep -q .; then
            echo "vendor/firmware/$b" >> "$propfile"
        else
            echo "Warning: $b not found."
        fi
    done
}

append_section() {
    local title="$1"
    shift
    echo -e "\n# $title - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "$propfile"
    for b in "$@"; do
        if find -type f -name "$b" -print -quit | grep -q .; then
            echo "vendor/firmware/$b" >> "$propfile"
        else
            echo "Warning: $b not found."
        fi
    done
}

append_with_sha1() {
    local title="$1"
    shift
    echo -e "\n# $title - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "$propfile"
    for b in "$@"; do
        if find -type f -name "$b" -print -quit | grep -q .; then
            local sha
            sha=$(sha1sum "$b" | awk '{print $1}')
            echo "vendor/firmware/$b|$sha" >> "$propfile"
        else
            echo "Warning: $b not found."
        fi
    done
}

append_with_modelpath_sha1() {
    local title="$1"
    shift
    echo -e "\n# $title - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "$propfile"
    for b in "$@"; do
        if find -type f -name "$b" -print -quit | grep -q .; then
            local sha
            sha=$(sha1sum "$b" | awk '{print $1}')
            echo "vendor/firmware/$MODEL/$b|$sha" >> "$propfile"
        else
            echo "Warning: $b not found."
        fi
    done
}

append_with_custompath() {
    local title="$1"
    shift
    echo -e "\n# $title - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "$propfile"
    for b in "$@"; do
        if find -type f -name "$b" -print -quit | grep -q .; then
            echo "vendor/firmware/$b:vendor/firmware/${MODEL}/$b" >> "$propfile"
        else
            echo "Warning: $b not found."
        fi
    done
}

append_tee_section() {
    local title="$1"
    local prefix="$2"
    echo -e "\n# $title - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "$propfile"
    find -type f | sed 's|^\./||' | sort | while read -r b; do
        echo "vendor/tee${prefix}$b${postfix}" >> "$propfile"
    done
}

append_tee_section_with_sha1() {
    local title="$1"
    local prefix="$2"
    echo -e "\n# $title - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "$propfile"
    find -type f | sed 's|^\./||' | sort | while read -r b; do
        sha=$(sha1sum "$b" | awk '{print $1}')
        echo "vendor/tee${prefix}$b|$sha" >> "$propfile"
    done
}

append_tee_section_with_modelpath() {
    local title="$1"
    local prefix="$2"
    echo -e "\n# $title - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "$propfile"
    find -type f | sed 's|^\./||' | sort | while read -r b; do
        echo "vendor/tee${prefix}$b:vendor/tee${prefix}$b" >> "$propfile"
    done
}

append_section_first "Audio - Firmware" "${audio_blobs[@]}"
append_section "Firmware" "${fw_blobs[@]}"
cd ../tee
append_tee_section "Security - TEEgris - Firmware" "/"

cd ../firmware
echo -e "\n# With sha1sum" >> "$propfile"
append_with_sha1 "Audio - Firmware" "${audio_blobs[@]}"
append_with_sha1 "Firmware" "${fw_blobs[@]}"
cd ../tee
append_tee_section_with_sha1 "Security - TEEgris - Firmware" "/"

cd ../firmware
echo -e "\n# With sha1sum and path to model" >> "$propfile"
append_with_modelpath_sha1 "Audio - Firmware" "${audio_blobs[@]}"
append_with_modelpath_sha1 "Firmware" "${fw_blobs[@]}"
cd ../tee
append_tee_section_with_sha1 "Security - TEEgris - Firmware" "/${MODEL}/" "|$(sha1sum "$b" | awk '{print $1}')"

cd ../firmware
echo -e "\n# With custom path" >> "$propfile"
append_with_custompath "Audio - Firmware" "${audio_blobs[@]}"
append_with_custompath "Firmware" "${fw_blobs[@]}"
cd ../tee
append_tee_section_with_modelpath "Security - TEEgris - Firmware" "/" ":vendor/tee/${MODEL}/$b"
