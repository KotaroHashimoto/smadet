Sub MT4データ読込み()

    Dim buf As String
    Dim tmp As Variant
    Dim n As Long
    
    n = 4
    
'    Open "C:\ここにMT4から出力されるファイルへのパスを入力してください\TrendAnalysis.csv" For Input As #1

        Line Input #1, buf
        Line Input #1, buf
    
        Do Until EOF(1)
            Line Input #1, buf
            tmp = Split(buf, ",")
            
            Cells(n, 3).Value = tmp(1)
            Cells(n, 5).Value = tmp(2)
            n = n + 1
        Loop
    Close #1
    
    Call ソート
    Call 上下
End Sub

