# JenkinsでAndroidアプリビルドを自動化する用のテンプレート
# 〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜
# ※プラグインとしてjenkinsに
#  　Subversion Plugin-in  ver2.5.3  
#  　Unit3d plugin  ver1.3
#  が入ってる事が前提。

# あらかじめ[ソースコード管理]で[Subversion]を指定してリポジトリにパスを通しておく。
# ([チェックアウト方式]は revertしてupdate 推奨。)　


# /_/_/_/_/ Build_1 /_/_/_/_/
# 古いapkを削除
if [ -e ${WORKSPACE}/buildsAndroid ];then
    rm -rf ${WORKSPACE}/buildsAndroid
fi
# /_/_/_/_/_/_/_/_/_/_/_/_/_/


# Build_1後、[Invoke Unity3d Editor]よりバッチモードでエディタ側のビルドを実行。
# (↑事前にプロジェクトにPostprocessなどを含めたビルドメソッドを実装しておく。)
# 例： -batchmode -buildTarget Android -executeMethod EditorGUIBuildSetting.BuildAndroidDebug -quit


# /_/_/_/_/ Build_2 /_/_/_/_/
# 成果物が各ジョブが置かれているディレクトリと同じ階層に置かれるので修正
cp -r /Users/MyPC/.jenkins/jobs/buildsAndroid ${WORKSPACE}/buildsAndroid
rm -rf /Users/MyPC/.jenkins/jobs/buildsAndroid
# /_/_/_/_/_/_/_/_/_/_/_/_/_/


# [ビルド後の処理]として[青果物を保存]を選択.[保存するファイル]を「*buildsAndroid/*.apk」としておけばOK.