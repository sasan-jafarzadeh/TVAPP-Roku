' AddSourceScene.brs




function myTrimAS(n as Integer) as String
    s = stri(n)
    result = ""
    for k = 1 to Len(s)
        c = Mid(s, k, 1)
        if c <> " " then result = result + c
    end for
    return result
end function

sub init()
    m.tabIdx     = 0   ' 0=M3U  1=Xtream
    m.focusArea  = "input"   ' "input" | "list" | "save" | "delete" | "cancel"

    m.tabM3U     = m.top.findNode("tabM3U")
    m.tabXtream  = m.top.findNode("tabXtream")
    m.tabUnder   = m.top.findNode("tabUnderline")
    m.panelM3U   = m.top.findNode("panelM3U")
    m.panelXtream= m.top.findNode("panelXtream")

    m.urlInput   = m.top.findNode("urlInput")
    m.xtHost     = m.top.findNode("xtHost")
    m.xtUser     = m.top.findNode("xtUser")
    m.xtPass     = m.top.findNode("xtPass")

    m.savedList  = m.top.findNode("savedList")
    m.msgLabel   = m.top.findNode("msgLabel")
    m.btnSave    = m.top.findNode("btnSave")
    m.btnDelete  = m.top.findNode("btnDelete")
    m.btnCancel  = m.top.findNode("btnCancel")


    m.reg = CreateObject("roRegistrySection", "IPTVSources")
    loadSavedSources()


    m.top.setFocus(true)
    m.urlInput.setFocus(true)
    highlightFocus()
end sub


sub loadSavedSources()
    keys = m.reg.GetKeyList()
    gc = CreateObject("RoSGNode", "ContentNode")
    for each k in keys
        raw = m.reg.Read(k)
        item = gc.createChild("ContentNode")
        item.title = raw
    end for
    m.savedList.content = gc
end sub


sub switchTab(idx as Integer)
    m.tabIdx = idx
    if idx = 0
        m.tabM3U.color    = "0xFFFFFFFF"
        m.tabXtream.color = "0x556688FF"
        m.tabUnder.translation = [400, 238]
        m.tabUnder.width  = 200
        m.panelM3U.visible    = true
        m.panelXtream.visible = false
        m.top.setFocus(true)
        m.urlInput.setFocus(true)
    else
        m.tabM3U.color    = "0x556688FF"
        m.tabXtream.color = "0xFFFFFFFF"
        m.tabUnder.translation = [640, 238]
        m.tabUnder.width  = 240
        m.panelM3U.visible    = false
        m.panelXtream.visible = true
        m.top.setFocus(true)
        m.xtHost.setFocus(true)
    end if
    m.focusArea = "input"
    highlightFocus()
end sub


function buildXtreamUrl() as String
    host = myTrimAS(m.xtHost.text)
    user = myTrimAS(m.xtUser.text)
    pass = myTrimAS(m.xtPass.text)
    if host = "" or user = "" or pass = "" then return ""

    if Right(host, 1) = "/" then host = Left(host, Len(host) - 1)
    return host + "/get.php?username=" + user + "&password=" + pass + "&type=m3u_plus&output=ts"
end function


sub doSave()
    m.msgLabel.text = ""
    finalUrl = ""

    if m.tabIdx = 0
        finalUrl = myTrimAS(m.urlInput.text)
        if finalUrl = ""
            m.msgLabel.text = "URL is empty!"
            return
        end if
        if Left(LCase(finalUrl), 4) <> "http"
            m.msgLabel.text = "Must start with http"
            return
        end if
    else
        finalUrl = buildXtreamUrl()
        if finalUrl = ""
            m.msgLabel.text = "Fill Host / User / Pass"
            return
        end if
    end if


    keys  = m.reg.GetKeyList()
    newKey = "src_" + myTrimAS(keys.Count())
    m.reg.Write(newKey, finalUrl)
    m.reg.Flush()

    m.msgLabel.text = "Saved!"
    loadSavedSources()


    m.urlInput.text = ""
    m.xtHost.text   = ""
    m.xtUser.text   = ""
    m.xtPass.text   = ""


    m.top.result = { type: "saved", url: finalUrl }
end sub


sub doDelete()
    if m.savedList.content = invalid then return
    idx  = m.savedList.itemFocused
    item = m.savedList.content.getChild(idx)
    if item = invalid then return

    raw = item.title   '   URL 
    keys = m.reg.GetKeyList()
    for each k in keys
        if m.reg.Read(k) = raw
            m.reg.Delete(k)
            m.reg.Flush()
            exit for
        end if
    end for

    m.msgLabel.text = "Deleted."
    loadSavedSources()
end sub


function myTrimAS(str as String) as String
    start  = 1
    endPos = Len(str)
    while start <= endPos and (Mid(str, start, 1) = " " or Mid(str, start, 1) = chr(13) or Mid(str, start, 1) = chr(10))
        start = start + 1
    end while
    while endPos >= start and (Mid(str, endPos, 1) = " " or Mid(str, endPos, 1) = chr(13) or Mid(str, endPos, 1) = chr(10))
        endPos = endPos - 1
    end while
    return Mid(str, start, endPos - start + 1)
end function


sub highlightFocus()
    m.btnSave.color   = "0x4A9FFFFF"
    m.btnDelete.color = "0xFF6666FF"
    m.btnCancel.color = "0x888888FF"
    if m.focusArea = "save"
        m.btnSave.color = "0xFFFFFFFF"
    else if m.focusArea = "delete"
        m.btnDelete.color = "0xFFAAAAFF"
    else if m.focusArea = "cancel"
        m.btnCancel.color = "0xFFFFFFFF"
    end if
end sub


function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back"
        m.top.closed = true
        return true
    end if


    if m.focusArea = "input"
        if key = "left" and m.tabIdx = 1
            switchTab(0)
            return true
        end if
        if key = "right" and m.tabIdx = 0
            switchTab(1)
            return true
        end if
        if key = "down"

            m.focusArea = "list"
            m.savedList.setFocus(true)
            highlightFocus()
            return true
        end if
    end if

    if m.focusArea = "list"
        if key = "up" and m.savedList.itemFocused = 0

            m.focusArea = "input"
            m.top.setFocus(true)
            if m.tabIdx = 0
                m.urlInput.setFocus(true)
            else
                m.xtHost.setFocus(true)
            end if
            highlightFocus()
            return true
        end if
        if key = "down"

            m.focusArea = "save"
            highlightFocus()
            return true
        end if
        if key = "ok"

            idx  = m.savedList.itemFocused
            item = m.savedList.content.getChild(idx)
            if item <> invalid
                if m.tabIdx = 0
                    m.urlInput.text = item.title
                else
                    m.xtHost.text = item.title
                end if
            end if
            return true
        end if
    end if

    if m.focusArea = "save" or m.focusArea = "delete" or m.focusArea = "cancel"
        if key = "left"
            if m.focusArea = "delete"
                m.focusArea = "save"
            else if m.focusArea = "cancel"
                m.focusArea = "delete"
            end if
            highlightFocus()
            return true
        end if
        if key = "right"
            if m.focusArea = "save"
                m.focusArea = "delete"
            else if m.focusArea = "delete"
                m.focusArea = "cancel"
            end if
            highlightFocus()
            return true
        end if
        if key = "up"
            m.focusArea = "list"
            m.savedList.setFocus(true)
            highlightFocus()
            return true
        end if
        if key = "ok"
            if m.focusArea = "save"
                doSave()
            else if m.focusArea = "delete"
                doDelete()
            else if m.focusArea = "cancel"
                m.top.closed = true
            end if
            return true
        end if
    end if


    if key = "play"
        doSave()
        return true
    end if

    return false
end function
