; ExportSchematicNetNames.il
; 用法: load 后, 在 Virtuoso 中打开/激活目标 schematic 窗口, 执行:
;   ExportSchematicNetNames()                          ; 导出到默认路径
;   ExportSchematicNetNames("D:/xxx/net_list.csv")     ; 导出到指定路径

procedure(ExportSchematicNetNames(@optional (filePath "C:/Users/liuzhengqing/Desktop/net_list.csv"))
    let((cv nets outPort count)
        cv = geGetEditCellView()
        unless(cv
            error("未找到当前活动的 schematic 窗口，请先打开并激活一个 schematic view。")
        )

        nets = cv~>nets
        outPort = outfile(filePath "w")
        unless(outPort
            error("无法打开文件 %s 进行写入。" filePath)
        )

        fprintf(outPort "Net Name\n")
        foreach(net nets
            fprintf(outPort "%s\n" net~>name)
        )
        close(outPort)

        count = length(nets)
        printf("已导出 %d 个 net name 到 %s\n" count filePath)
        filePath
    )
)
