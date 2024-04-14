# targetDir のディレクトリ毎のファイル数を数える
$targetDir = ‘~/test'
# ディレクトリの一覧取得
$dirs = Get-Childitem -Path $targetDir -Recurse -Directory
# ％：foreach
$dirs | % { write-host 場所:$_.FullName, ファイル合計:(Get-ChildItem $_ -recurse -File | Measure-Object).count , 内数(Get-ChildItem $_ -File | Measure-Object).count }
