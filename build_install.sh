flutter build apk
adb install -r ./build/app/outputs/flutter-apk/app-release.apk

if which xsel > /dev/null; then
    cat ./build/app/outputs/flutter-apk/app-release.apk.sha1 | xsel --clipboard --input
else
    echo "xsel not found"
    echo
    echo "app-release.apk.sha1"
    cat ./build/app/outputs/flutter-apk/app-release.apk.sha1
fi