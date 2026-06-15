hiSetBindKey("Schematics" "a" "addPinsToSelectedInst()")

procedure(addPinsToSelectedInst()
    let((sel cv inst instTerms term dir pinName pinUse pinMasterName pinMaster pinFig ll ur cx cy masterPt instPt orient dx dy newPinPt offset instBBox instCX instCY)
        sel = geGetSelectedSet()
        
        ;; 【配置】：Pin 和器件之间拉开的线长
        offset = 0.5  
        
        if(sel && length(sel) == 1 && car(sel)~>objType == "inst" then
            inst = car(sel)
            cv = inst~>cellView
            instTerms = inst~>instTerms
            
            instBBox = inst~>bBox
            instCX = (xCoord(car(instBBox)) + xCoord(cadr(instBBox))) / 2.0
            instCY = (yCoord(car(instBBox)) + yCoord(cadr(instBBox))) / 2.0
            
            if(instTerms then
                foreach(it instTerms
                    term = it~>term
                    dir = term~>direction
                    pinName = term~>name
                    pinUse = if(term~>use term~>use "signal")
                    
                    pinMasterName = case(dir
                        ("input" "ipin")
                        ("output" "opin")
                        ("inputOutput" "iopin")
                        (t "iopin")
                    )
                    pinMaster = dbOpenCellViewByType("basic" pinMasterName "symbol")
                    
                    if(pinMaster then
                        pinFig = car(term~>pins)~>fig
                        if(pinFig && pinFig~>bBox then
                            ll = car(pinFig~>bBox)
                            ur = cadr(pinFig~>bBox)
                            cx = (xCoord(ll) + xCoord(ur)) / 2.0
                            cy = (yCoord(ll) + yCoord(ur)) / 2.0
                            masterPt = list(cx cy)
                        else
                            masterPt = list(0 0)
                        )
                        
                        instPt = dbTransformPoint(masterPt inst~>transform)
                        
                        dx = xCoord(instPt) - instCX
                        dy = yCoord(instPt) - instCY
                        
                        if(abs(dx) > abs(dy) then
                            if(dx > 0 then
                                orient = "R180"
                                newPinPt = list(xCoord(instPt) + offset yCoord(instPt))
                            else
                                orient = "R0"
                                newPinPt = list(xCoord(instPt) - offset yCoord(instPt))
                            )
                        else
                            if(dy > 0 then
                                orient = "R270"
                                newPinPt = list(xCoord(instPt) yCoord(instPt) + offset)
                            else
                                orient = "R90"
                                newPinPt = list(xCoord(instPt) yCoord(instPt) - offset)
                            )
                        )
                        
                        ;; 创建 Pin
                        schCreatePin(cv pinMaster pinName dir pinUse newPinPt orient)
                        
                        ;; 【完美修复】：补齐了 width, spacing, delta 三个浮点参数 (0.0 0.0 0.0)
                        schCreateWire(cv "draw" "full" list(instPt newPinPt) 0.0 0.0 0.0)
                        
                        printf("Auto added pin & wire for: %s (Dir: %s) at %L\n" pinName dir newPinPt)
                    else
                        printf("Error: Could not open basic library pin master '%s'.\n" pinMasterName)
                    )
                )
                schCheck(cv)
                printf("Successfully added %d pins with wires for instance '%s'.\n" length(instTerms) inst~>name)
            else
                printf("Warning: No internal pins found for the selected instance.\n")
            )
        else
            printf("Error: Please select exactly ONE instance in the schematic.\n")
        )
    )
)
