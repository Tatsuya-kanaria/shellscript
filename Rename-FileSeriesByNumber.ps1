Function Rename-FileSeries {
    # PowerShell 5.1/7 の両方で動作する高度な関数定義
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SubFolderName, # 連番を振り直す対象のサブフォルダ名

        [int]$Digit = 2 # 新しい連番の桁数（例: 2桁なら 01, 02, ...）
    )

    # スクリプト実行時のカレントディレクトリをベースパスとする
    $BasePath = (Get-Location).Path
    $Path = Join-Path -Path $BasePath -ChildPath $SubFolderName

    # ターゲットパスが存在しない場合はエラー
    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Error "指定されたフォルダが見つかりません: $Path"
        Write-Verbose "ベースパス: $BasePath"
        return
    }

    Write-Host "--- 処理を開始します ---"
    Write-Host "対象フォルダ: $Path"
    Write-Host "連番の桁数: $Digit"
    Write-Host "---"

    # 1. 対象フォルダ内のファイルを元の名前順で取得
    $Files = Get-ChildItem -Path $Path -File |
    #    ファイル名に "copy" を含むファイルは除外します
    # Where-Object { $_.Name -notlike "*copy*" } | # 除外するファイル名がある場合に指定する
    Sort-Object Name

    if ($Files.Count -eq 0) {
        Write-Warning "対象フォルダ内に処理すべきファイル（'copy' を含まないファイル）が見つかりませんでした。"
        return
    }

    Write-Host "取得したファイル数: $($Files.Count) 件"
    Write-Host "---"

    # 2. カウンターの初期化
    $i = 1

    foreach ($File in $Files) {
        # 3. 新しい連番の作成
        $NewNumber = "{0:D$Digit}" -f $i

        # 4. 新しいファイル名ベースの作成（既存の連番 (^\d{n}_) を削除, nは-Digitで指定）
        # 例: $Digit=2 の場合、"03_Title.ext" の "03_" 部分にマッチ
        #     $Digit=3 の場合、"003_Title.ext" の "003_" 部分にマッチ
        $Pattern = '^\d{' + $Digit + '}_'
        $BaseName = $File.BaseName -replace $Pattern, ''

        $NewName = "$NewNumber" + "_" + "$BaseName$($File.Extension)"
        $OriginalName = $File.Name

        # 1. -WhatIf モードの場合、カスタム表示を行う
        if ($WhatIfPreference) {
            # 実行前シミュレーションとして、リネーム後の名前を表示
            Write-Host "WHATIF: '$OriginalName' -> '$NewName'" -ForegroundColor Yellow

            # 標準の 'What If: Performing...' も出るが、カスタム表示が優先される
            $i++ # カウンターは常にインクリメント
        }
        else {
            # ShouldProcessを実行し、リネームの可否を判断
            $ProcessResult = $PSCmdlet.ShouldProcess($OriginalName, "連番振り直し")
            # 2. ShouldProcess で確認し、リネームを実行
            if ($ProcessResult) {
                # 実際のリネーム処理
                Rename-Item -Path $File.FullName -NewName $NewName

                # 実際のリネーム時のみ、実行結果を表示
                Write-Host "RENAME: '$OriginalName' -> '$NewName'" -ForegroundColor Green
                $i++ # カウンターは常にインクリメント
            }
        }
    }

    Write-Host "---"
    Write-Host "すべての処理が完了しました。"
}

### 使用例
# シミュレーション実行
# スクリプトファイルと同じフォルダ内の Data サブフォルダを対象に、2桁連番（デフォルト）でリネーム後の名前を確認します。
# Rename-FileSeries -SubFolderName "Data" -WhatIf

# 実際のリネーム
# シミュレーションで問題がなかった場合、-WhatIf を外して実際にファイル名を変更します。
# Rename-FileSeries -SubFolderName "Data"

# 桁数の変更
# Reports サブフォルダを対象に、3桁の連番（001, 002...）でリネームを実行します。
# Rename-FileSeries -SubFolderName "Reports" -Digit 3
