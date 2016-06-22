# JenkinsでiOSアプリビルドを自動化する用のテンプレート
# 〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜
# ※プラグインとしてjenkinsに
#  　Subversion Plugin-in  ver2.5.3  
#  　Unit3d plugin  ver1.3
#  が入ってる事が前提。

# あらかじめ[ソースコード管理]で[Subversion]を指定してリポジトリにパスを通しておく。
# ([チェックアウト方式]は revertしてupdate 推奨。)　


# /_/_/_/_/ Build_1 /_/_/_/_/
# 古いXcodeproj,ipaを削除
if [ -e /Users/MyPC/.jenkins/jobs/builds ]; then
	rm -rf /Users/MyPC/.jenkins/jobs/builds
fi
if [ -e *.ipa ];then
    rm *.ipa
fi
if [ -d Payload ];then
  rm -rf Payload
fi
# /_/_/_/_/_/_/_/_/_/_/_/_/_/


# Build_1後、[Invoke Unity3d Editor]よりバッチモードでエディタ側のビルドを実行。
# (↑事前にプロジェクトにPostprocessなどを含めたビルドメソッドを実装しておく。)
# 例： -batchmode -buildTarget ios -executeMethod EditorGUIBuildSetting.BuildiOSDebug -quit


# /_/_/_/_/ Build_2 /_/_/_/_/
# >>>>>>>>>>>>>>>>>Xcodeビルド実行>>>>>>>>>>>>>>>>>>>>>>>
XCODEPROJ_DIR=$(ls -dF /Users/MyPC/.jenkins/jobs/builds/*)

# キーチェインの準備
echo "キーチェインの準備...."
KEYCHAIN_LOCATION=$HOME/Library/Keychains/login.keychain
KEYCHAIN_PASSWARD=passward

echo "キーチェインアクセス...."
/usr/bin/security list-keychains -s $KEYCHAIN_LOCATION
/usr/bin/security default-keychain -d user -s $KEYCHAIN_LOCATION
/usr/bin/security unlock-keychain -p $KEYCHAIN_PASSWARD $KEYCHAIN_LOCATION

# xcode ビルド
echo "xcode ビルド開始...."
PROJECT_DIR=${XCODEPROJ_DIR}Unity-iPhone.xcodeproj
TARGET_NAME=Unity-iPhone
CONFIGURATION=Release       # 作りたいアプリによって変える.ジョブ単位で分けても良いかも.
OUTPUT_DIR=output
CODE_IDENTITY="hogehoge"    # 署名.ビルド権限のある人のを設定.

/usr/bin/xcodebuild -project "${PROJECT_DIR}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" clean build CONFIGURATION_BUILD_DIR="${OUTPUT_DIR}" CODE_SIGN_IDENTITY="${CODE_IDENTITY}" OTHER_CODE_SIGN_FLAGS="--keychain ${KEYCHAIN_LOCATION}"

# ipa ファイル作成
echo "ipa ファイル作成開始...."
TARGET_APP_PATH="${XCODEPROJ_DIR}${OUTPUT_DIR}/sample_test.app"
IPA_FILE_NAME="SAMPLE_iOS_RELEASE_$(date "+%Y%m%d-%H%M%S").ipa"
IPA_FILE_PATH=${WORKSPACE}/${IPA_FILE_NAME}
PROVISIONING_FILE_PATH=/Users/MyPC/MyData/tools/dev_provisioning.mobileprovision   # プロビジョニングプロファイル格納場所のパスをここに指定.

/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${TARGET_APP_PATH}" -o "${IPA_FILE_PATH}" --sign "${CODE_IDENTITY}" --embed "${PROVISIONING_FILE_PATH}"
# /_/_/_/_/_/_/_/_/_/_/_/_/_/


# [ビルド後の処理]として[青果物を保存]を選択.[保存するファイル]を「*.ipa」としておけばOK.