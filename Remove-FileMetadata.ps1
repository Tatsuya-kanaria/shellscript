Function Remove-FileMetadata {
    # -WhatIf, -Confirm に対応
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SubFolderName # 処理対象のサブフォルダ名
    )

    # 実行時のカレントディレクトリとサブフォルダ名を結合してパスを構築
    $BasePath = (Get-Location).Path
    $Path = Join-Path -Path $BasePath -ChildPath $SubFolderName

    # ターゲットパスが存在しない場合はエラー
    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Error "指定されたフォルダが見つかりません: $Path"
        return
    }

    Write-Host "--- 処理を開始します ---"
    Write-Host "対象フォルダ: $Path"
    Write-Host "---"

    # 対象フォルダ内のファイルを元の名前順で取得
    $Files = Get-ChildItem -Path $Path -File | Sort-Object Name

    if ($Files.Count -eq 0) {
        Write-Warning "対象フォルダ内に処理すべきファイルが見つかりませんでした。"
        return
    }

    Write-Host "取得したファイル数: $($Files.Count) 件"
    Write-Host "---"

    foreach ($File in $Files) {
        $OriginalName = $File.Name

        # 🌟 修正ロジック: ファイル名全体から括弧の始まりとそれ以降を削除 🌟
        # $File.Name ではなく $File.BaseName を使用し、ファイル名（拡張子なし）を対象とします。
        # '\s*\(.*' : スペース(0回以上)と括弧の始まり '(' から、文字列の末尾まで全てにマッチ
        $BaseNameOnly = $File.BaseName -replace '\s*\(.*', ''

        # 新しいファイル名（拡張子付き）を構築
        $NewName = $BaseNameOnly + $File.Extension

        # 処理前の名前と処理後の名前が同じ場合はスキップ
        if ($OriginalName -eq $NewName) {
            Write-Verbose "スキップ: '$OriginalName' - 括弧が見つかりませんでした。"
            continue
        }

        $IsWhatIf = $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('WhatIf')
        # ShouldProcessを実行し、リネームの可否を判断
        $ProcessResult = $PSCmdlet.ShouldProcess($OriginalName, "括弧から末尾までの削除")

        # 1. -WhatIf モードの場合、カスタムでリネーム後の名前を表示
        if ($IsWhatIf) {
            Write-Host "WHATIF: '$OriginalName' -> '$NewName'" -ForegroundColor Yellow
        }

        # 2. ShouldProcess で確認し、リネームを実行
        if ($ProcessResult) {

            # Rename-Item自体に-WhatIfの有無を任せる
            Rename-Item -Path $File.FullName -NewName $NewName

            # 実際のリネーム時のみ、実行結果を表示
            if (-not $IsWhatIf) {
                Write-Host "RENAME: '$OriginalName' -> '$NewName'" -ForegroundColor Green
            }
        }
    }

    Write-Host "---"
    Write-Host "すべての削除処理が完了しました。"
}

### 使用例
# シミュレーション実行
# OldFiles サブフォルダを対象に、削除後の名前を確認します。
# Remove-FileMetadata -SubFolderName "OldFiles" -WhatIf

# 実際のリネーム
# シミュレーションで問題がなかった場合、-WhatIf を外して実際にファイル名を変更します。
# Remove-FileMetadata -SubFolderName "OldFiles"
