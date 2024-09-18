#!/bin/bash

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "build_install.sh \"version\" (optional)"
fi

if [[ -z "$1" ]]; then
    VERSION="0.5.0b"
else
    VERSION=$(grep 'version:' pubspec.yaml | cut -d ' ' -f 2)
fi

echo "Building Android APK file"
flutter build apk

echo "To install on Android (with phone connected) execute: adb install -r ./build/app/outputs/flutter-apk/app-release.apk"
echo "Do you want to install (y/N)"
read INSTALL_ANDROID
if [[ "${INSTALL_ANDROID,,}" == "y" ]]; then
    adb install -r ./build/app/outputs/flutter-apk/app-release.apk
fi

if which xsel > /dev/null; then
    cat ./build/app/outputs/flutter-apk/app-release.apk.sha1 | xsel --clipboard --input
else
    echo "xsel not found"
    echo
    echo "app-release.apk.sha1"
    cat ./build/app/outputs/flutter-apk/app-release.apk.sha1
fi

echo "Building Linux Executable"
flutter build linux

echo "Creating a script for install (it will be inserted into zip file and after deleted)"

cat <<EOF > ./install.sh
#!/bin/bash

# Checking if the programs has root privilegies
if [ "\$EUID" -ne 0 ]; then
    echo "Required root permission"
    exit 1
fi

echo "Copying bin"
sudo cp -r ./lib /usr/local/bin/
sudo cp -r ./data /usr/local/bin/
sudo cp ./data_storage /usr/local/bin/data-storage
sudo chmod +x /usr/local/bin/data-storage

echo "Copying icons"
ICON_PATH=/usr/share/icons/hicolor/
mkdir -p \$ICON_PATH
mkdir -p \$ICON_PATH/16x16/apps
mkdir -p \$ICON_PATH/32x32/apps/
mkdir -p \$ICON_PATH/48x48/apps/
mkdir -p \$ICON_PATH/64x64/apps/
mkdir -p \$ICON_PATH/128x128/apps/
mkdir -p \$ICON_PATH/256x256/apps/
mkdir -p \$ICON_PATH/1024x1024/apps/

sudo cp ./icons-nobg/data-storage-16.png \$ICON_PATH/16x16/apps/datastorage.png
sudo cp ./icons-nobg/data-storage-32.png \$ICON_PATH/32x32/apps/datastorage.png
sudo cp ./icons-nobg/data-storage-48.png \$ICON_PATH/48x48/apps/datastorage.png
sudo cp ./icons-nobg/data-storage-64.png \$ICON_PATH/64x64/apps/datastorage.png
sudo cp ./icons-nobg/data-storage-128.png \$ICON_PATH/128x128/apps/datastorage.png
sudo cp ./icons-nobg/data-storage-256.png \$ICON_PATH/256x256/apps/datastorage.png
sudo cp ./icons-nobg/data-storage-1024.png \$ICON_PATH/1024x1024/apps/datastorage.png

echo "Saving .desktop file"
echo "[Desktop Entry]
Version=$VERSION
Name=Data Storage
Comment=A program that collect data
Exec=/usr/local/bin/data-storage
Icon=datastorage
Terminal=false
Type=Application
Categories=Utility;Application;" | sudo tee /usr/share/applications/data_storage.desktop

echo "Installing completed!"
EOF

chmod +x install.sh
chmod +x ./build/linux/x64/release/bundle/data_storage
echo "Building Installing .zip (Linux)"
rm linux-installer-x64.zip

# adding install script, bin, README.md
zip -j linux-installer-x64.zip ./install.sh ./android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_beta.png ./build/linux/x64/release/bundle/data_storage ./README.md

# adding bin dependencies
cd ./build/linux/x64/release/bundle
zip -r ./../../../../../linux-installer-x64.zip ./lib/ ./data/
cd ./../../../../../

# adding icons
cd ./assets/
zip -r ../linux-installer-x64.zip ./icons-nobg/
cd ..

rm ./install.sh