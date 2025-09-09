#!/usr/bin/env bash
set -euo pipefail

OUT="../../proprietary-files/proprietary.${MODEL}_${CSC}_${OMC}"
rm -f "$OUT"

cd vendor/firmware

audio_blobs=( "APDV_AUDIO_SLSI.bin" "AP_AUDIO_SLSI.bin" "calliope_sram.bin" "vts.bin" )
sudo grep -q "m34" "../mount/build.prop" && audio_blobs=( "calliope_sram.bin" "vts.bin" )

fw_blobs=( "NPU.bin" "mfc_fw.bin" "os.checked.bin" )
[[ -f "nfc/libsn100u_fw.so" ]] && fw_blobs+=( "nfc/libsn100u_fw.so" )

write_section() {
    local header="$1"; shift
    echo "$header" >> "$OUT"
}

append_blob() {
    local base="$1" dest="$2" sha="$3"
    if find -type f -name "$base" -print -quit | grep -q .; then
        local line="vendor/firmware/$base"
        [[ -n "$dest" ]] && line="$line:$dest"
        [[ "$sha" == "1" ]] && line="$line|$(sha1sum "$base" | awk '{print $1}')"
        echo "$line" >> "$OUT"
    else
        echo "Warning: $base not found."
    fi
}

append_blobs() {
    local title="$1" mode="$2" sha="$3" tee_path="$4"
    write_section "# $title - from ${MODEL} - ${LATEST_SHORTVERSION}"

    local blobs=("${!5}")
    for b in "${blobs[@]}"; do
        case "$mode" in
            plain)        append_blob "$b" "" "$sha" ;;
            custom)       append_blob "$b" "vendor/firmware/${MODEL}/$b" "$sha" ;;
            tee_plain)    echo "vendor/tee/$b${sha:+|$(sha1sum "$b" | awk '{print $1}')}" >> "$OUT" ;;
            tee_custom)   echo "vendor/tee/$b:vendor/tee/${MODEL}/$b${sha:+|$(sha1sum "$b" | awk '{print $1}')}" >> "$OUT" ;;
        esac
    done
    echo "" >> "$OUT"
}

append_tee() {
    local title="$1" mode="$2" sha="$3"
    write_section "# $title - from ${MODEL} - ${LATEST_SHORTVERSION}"
    find -type f | sed 's|^\./||' | sort | while read -r b; do
        case "$mode" in
            plain)  echo "vendor/tee/$b${sha:+|$(sha1sum "$b" | awk '{print $1}')}" >> "$OUT" ;;
            custom) echo "vendor/tee/$b:vendor/tee/${MODEL}/$b${sha:+|$(sha1sum "$b" | awk '{print $1}')}" >> "$OUT" ;;
        esac
    done
}

# Normal
append_blobs "Audio Firmware"    plain 0  "" audio_blobs[@]
append_blobs "Firmware"          plain 0  "" fw_blobs[@]
cd ../tee && append_tee "TEEgris Firmware" plain 0

# With sha1sum
echo "" >> "$OUT"
cd ../firmware
append_blobs "Audio Firmware"    plain 1 "" audio_blobs[@]
append_blobs "Firmware"          plain 1 "" fw_blobs[@]
cd ../tee && append_tee "TEEgris Firmware" plain 1

# Custom path
echo "" >> "$OUT"
cd ../firmware
append_blobs "Audio Firmware"    custom 0 "" audio_blobs[@]
append_blobs "Firmware"          custom 0 "" fw_blobs[@]
cd ../tee && append_tee "TEEgris Firmware" custom 0
