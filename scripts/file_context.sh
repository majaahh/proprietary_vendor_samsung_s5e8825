print_entry_file() {
    local path="$1"
    local label="$2"
    echo "$path $label"
}

generate_file_contexts() {
    local base="$1"
    local default_label="$2"
    declare -A custom_labels=(
        ["NPU.bin"]="u:object_r:vendor_npu_firmware_file:s0"
    )
    local base_context_path="/vendor/${base#vendor/}"
    print_entry_file "$base_context_path" "$default_label"
    find "$base" -type f -o -type d | sort | while read -r fullpath; do
        if [[ "$fullpath" == "$base" ]]; then
            continue
        fi
        relpath="${fullpath#$base/}"
        context_path="/vendor/${base#vendor/}/$(printf "%s" "$relpath" | sed 's/\./\\./g')"
        if [[ -n "${custom_labels[$relpath]}" ]]; then
            label="${custom_labels[$relpath]}"
        else
            label="$default_label"
        fi
        print_entry_file "$context_path" "$label"
    done
}

[[ ! -d "file_context/$BOARD" ]] && mkdir -p "file_context/$BOARD"

{
    if ! sudo grep -q "m34" "vendor/mount/build.prop"; then
        echo "/vendor/firmware/AP_AUDIO_SLSI\.bin u:object_r:vendor_fw_file:s0"
        echo "/vendor/firmware/APDV_AUDIO_SLSI\.bin u:object_r:vendor_fw_file:s0"
    fi
    echo "/vendor/firmware/calliope_sram\.bin u:object_r:vendor_fw_file:s0"
    echo "/vendor/firmware/mfc_fw\.bin u:object_r:vendor_fw_file:s0"
    echo "/vendor/firmware/NPU\.bin u:object_r:vendor_npu_firmware_file:s0"
    echo "/vendor/firmware/os\.checked\.bin u:object_r:vendor_fw_file:s0"
    echo "/vendor/firmware/vts\.bin u:object_r:vendor_fw_file:s0"
    generate_file_contexts "vendor/tee" "u:object_r:tee_file:s0"
} > "file_context/$BOARD/file.${MODEL}_${CSC}_${OMC}"

mv vendor/tee vendor/tee_old
mkdir -p vendor/tee/${MODEL}
cp -rfa vendor/tee_old/* vendor/tee/${MODEL}

{
    echo ""
    echo "# Custom Path"
    echo "/vendor/firmware/${MODEL} u:object_r:vendor_fw_file:s0"
    if ! sudo grep -q "m34" "vendor/mount/build.prop"; then
        echo "/vendor/firmware/${MODEL}/AP_AUDIO_SLSI\.bin u:object_r:vendor_fw_file:s0"
        echo "/vendor/firmware/${MODEL}/APDV_AUDIO_SLSI\.bin u:object_r:vendor_fw_file:s0"
    fi
    echo "/vendor/firmware/${MODEL}/calliope_sram\.bin u:object_r:vendor_fw_file:s0"
    echo "/vendor/firmware/${MODEL}/mfc_fw\.bin u:object_r:vendor_fw_file:s0"
    echo "/vendor/firmware/${MODEL}/NPU\.bin u:object_r:vendor_npu_firmware_file:s0"
    echo "/vendor/firmware/${MODEL}/os\.checked\.bin u:object_r:vendor_fw_file:s0"
    echo "/vendor/firmware/${MODEL}/vts\.bin u:object_r:vendor_fw_file:s0"
    generate_file_contexts "vendor/tee/${MODEL}" "u:object_r:tee_file:s0"
} >> "file_context/$BOARD/file.${MODEL}_${CSC}_${OMC}"

rm -rf vendor/tee/${MODEL}
cp -rfa vendor/tee_old/* vendor/tee
