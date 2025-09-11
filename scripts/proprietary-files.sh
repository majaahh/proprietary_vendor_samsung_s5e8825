[[ -f "proprietary-files/proprietary.${MODEL}_${OMC}" ]] && rm -f "proprietary-files/proprietary.${MODEL}_${OMC}"
cd vendor/firmware
audio_blobs=( "APDV_AUDIO_SLSI.bin" "AP_AUDIO_SLSI.bin" "calliope_sram.bin" "vts.bin" )
sudo grep -q "m34" "../mount/build.prop" && audio_blobs=( "calliope_sram.bin" "vts.bin" )

fw_blobs=( "NPU.bin"  "mfc_fw.bin" "os.checked.bin" )
[[ -f "nfc/libsn100u_fw.so" ]] && fw_blobs+=( "nfc/libsn100u_fw.so" )

#####################################################################################

echo "# Audio Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
for b in "${audio_blobs[@]}"; do
    if find -type f -name "$b" -print -quit | grep -q .; then
        echo "vendor/firmware/$b" \
        >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
    else
        echo "Warning: $b not found."
    fi
done
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"

echo "# Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
for b in "${fw_blobs[@]}"; do
    if find -type f -name "$b" -print -quit | grep -q .; then
        echo "vendor/firmware/$b" \
        >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
    else
        echo "Warning: $b not found."
    fi
done
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"

cd ../tee
echo "# TEEgris Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
find -type f | sed 's|^\./||' | sort | while read -r b; do
    echo "vendor/tee/$b" \
    >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
done

#####################################################################################

cd ../firmware
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
echo "# With sha1sum" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
echo "# Audio Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
for b in "${audio_blobs[@]}"; do
    if find -type f -name "$b" -print -quit | grep -q .; then
        echo "vendor/firmware/$b|$(sha1sum "$b" | awk '{print $1}')" \
        >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
    else
        echo "Warning: $b not found."
    fi
done
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"

echo "# Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
for b in "${fw_blobs[@]}"; do
    if find -type f -name "$b" -print -quit | grep -q .; then
        echo "vendor/firmware/$b|$(sha1sum "$b" | awk '{print $1}')" \
        >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
    else
        echo "Warning: $b not found."
    fi
done
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"

cd ../tee
echo "# TEEgris Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
find -type f | sed 's|^\./||' | sort | while read -r b; do
    echo "vendor/tee/$b|$(sha1sum "$b" | awk '{print $1}')" \
    >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
done

#####################################################################################

cd ../firmware
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
echo "# With sha1sum and path to model" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
echo "# Audio Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
for b in "${audio_blobs[@]}"; do
    if find -type f -name "$b" -print -quit | grep -q .; then
        echo "vendor/firmware/${MODEL}/$b|$(sha1sum "$b" | awk '{print $1}')" \
        >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
    else
        echo "Warning: $b not found."
    fi
done
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"

echo "# Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
for b in "${fw_blobs[@]}"; do
    if find -type f -name "$b" -print -quit | grep -q .; then
        echo "vendor/firmware/${MODEL}/$b|$(sha1sum "$b" | awk '{print $1}')" \
        >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
    else
        echo "Warning: $b not found."
    fi
done
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"

cd ../tee
echo "# TEEgris Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
find -type f | sed 's|^\./||' | sort | while read -r b; do
    echo "vendor/tee/${MODEL}/$b|$(sha1sum "$b" | awk '{print $1}')" \
    >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
done

#####################################################################################

cd ../firmware
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
echo "# With custom path" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
echo "# Audio Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
for b in "${audio_blobs[@]}"; do
    if find -type f -name "$b" -print -quit | grep -q .; then
        echo "vendor/firmware/$b:vendor/firmware/${MODEL}/$b" \
        >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
    else
        echo "Warning: $b not found."
    fi
done
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"

echo "# Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
for b in "${fw_blobs[@]}"; do
    if find -type f -name "$b" -print -quit | grep -q .; then
        echo "vendor/firmware/$b:vendor/firmware/${MODEL}/$b" \
        >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
    else
        echo "Warning: $b not found."
    fi
done
echo "" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"

cd ../tee
echo "# TEEgris Firmware - from ${MODEL} - ${LATEST_SHORTVERSION}" >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
find -type f | sed 's|^\./||' | sort | while read -r b; do
    echo "vendor/tee/$b:vendor/tee/${MODEL}/$b" \
    >> "../../proprietary-files/proprietary.${MODEL}_${OMC}"
done
