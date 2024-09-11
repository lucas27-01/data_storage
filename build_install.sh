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

echo "Creating Application Directory"
sudo mkdir /usr/local/bin/data-storage

echo "Copying bin"
sudo cp ./lib /usr/local/bin/data-storage/
sudo cp ./data /usr/local/bin/data-storage/
sudo cp ./data_storage /usr/local/bin/data-storage/data-storage
sudo chmod +x /usr/local/bin/data-storage/data-storage

echo "Copying icon"
sudo cp ./ic_launcher_beta.png /usr/share/icons/data-storage.png

echo "Saving .desktop file"
echo "[Desktop Entry]
Version=$VERSION
Name=Data Storage
Comment=A program that collect data
Exec=/usr/local/bin/data-storage/data-storage/data-storage
Icon=/usr/share/icons/data-storage.png
Terminal=false
Type=Application
Categories=Utility;Application;" | sudo tee /usr/share/applications/data_storage.desktop

echo "Installing completed!"
EOF

chmod +x install.sh
chmod +x ./build/linux/x64/release/bundle/data_storage
echo "Building Installing .zip (Linux)"
zip -j -r linux-installer-x64.zip ./install.sh ./android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_beta.png ./build/linux/x64/release/bundle/

rm ./install.sh