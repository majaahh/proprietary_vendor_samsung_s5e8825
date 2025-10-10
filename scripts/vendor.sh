tar xvf ${AP_TAR} super.img.lz4
lz4 -d super.img.lz4 super.img
rm -f super.img.lz4
simg2img super.img super_raw.img
rm -f super.img
mv -f super_raw.img super.img
./tools/lpunpack -p vendor super.img . || true
[[ ! -f "vendor.img" ]] && ./tools/lpunpack super.img || true
rm -f super.img system*.img vendor_dlkm*.img odm*.img product*.img || true
[[ -f "vendor_a.img" ]] && mv -f "vendor_a.img" "vendor.img"

zip ${LATEST_SHORTVERSION}_vendor.zip vendor.img

mkdir -p vendor vendor_mount
sudo mount vendor.img vendor_mount

# https://github.com/salvogiangri/UN1CA/blob/fifteen/scripts/extract_fw.sh#L135-L136
sudo cp -fa -T vendor_mount vendor
sudo chown -hR "$(whoami):$(whoami)" vendor
sudo umount vendor_mount

cp -rfa vendor/firmware/* vendor/firmware/${MODEL}
cp -rfa vendor/tee/* vendor/tee/${MODEL}

zip -r0 --store ${LATEST_SHORTVERSION}_vendor-extracted.zip vendor
rm -rf vendor_mount
