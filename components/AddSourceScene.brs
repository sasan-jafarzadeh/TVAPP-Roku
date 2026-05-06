sub init()
    m.tabIdx    = 0
    m.xtField   = 0
    m.focusArea = "keyboard"
    m.lastSavedUrl = ""
    m.didSave      = false

    m.tabM3U      = m.top.findNode("tabM3U")
    m.tabXtream   = m.top.findNode("tabXtream")
    m.tabUnder    = m.top.findNode("tabUnderline")
    m.panelM3U    = m.top.findNode("panelM3U")
    m.panelXtream = m.top.findNode("panelXtream")

    m.urlDisplay    = m.top.findNode("urlDisplay")
    m.xtHostDisplay = m.top.findNode("xtHostDisplay")
    m.xtUserDisplay = m.top.findNode("xtUserDisplay")
    m.xtPassDisplay = m.top.findNode("xtPassDisplay")
    m.fieldLabel    = m.top.findNode("fieldLabel")

    m.keyboard  = m.top.findNode("inputKeyboard")
    m.savedList = m.top.findNode("savedList")
    m.msgLabel  = m.top.findNode("msgLabel")
    m.btnSave   = m.top.findNode("btnSave")
    m.btnDelete = m.top.findNode("btnDelete")
    m.btnCancel = m.top.findNode("btnCancel")

    m.urlText  = ""
    m.hostText = ""
    m.userText = ""
    m.passText = ""

    m.reg = CreateObject("roRegistrySection", "IPTVSources")
    loadSavedSources()

    m.keyboard.observeField("text", "onKeyboardText")
    switchTab(0)
    m.keyboard.setFocus(true)
    highlightFocus()
end sub

sub onKeyboardText()
    txt = m.keyboard.text
    if m.tabIdx = 0
        m.urlText         = txt
        m.urlDisplay.text = txt
    else
        if m.xtField = 0
            m.hostText            = txt
            m.xtHostDisplay.text  = txt
        else if m.xtField = 1
            m.userText            = txt
            m.xtUserDisplay.text  = txt
        else
            m.passText            = txt
            m.xtPassDisplay.text  = txt
        end if
    end if
end sub

sub switchTab(idx as Integer)
    m.tabIdx  = idx
    m.xtField = 0
    if idx = 0
        m.tabM3U.color    = "0xFFFFFFFF"
        m.tabXtream.color = "0x556688FF"
        m.tabUnder.translation = [200, 178]
        m.tabUnder.width       = 220
        m.panelM3U.visible     = true
        m.panelXtream.visible  = false
        m.fieldLabel.text      = "URL:"
        m.keyboard.text        = m.urlText
    else
        m.tabM3U.color    = "0x556688FF"
        m.tabXtream.color = "0xFFFFFFFF"
        m.tabUnder.translation = [460, 178]
        m.tabUnder.width       = 280
        m.panelM3U.visible    = false
        m.panelXtream.visible = true
        setXtField(0)
    end if
    m.focusArea = "keyboard"
    m.keyboard.setFocus(true)
    highlightFocus()
end sub

sub setXtField(f as Integer)
    m.xtField = f
    if f = 0
        m.fieldLabel.text     = "Server URL:"
        m.keyboard.text       = m.hostText
        m.xtHostDisplay.color = "0xFFFFFFFF"
        m.xtUserDisplay.color = "0x888888FF"
        m.xtPassDisplay.color = "0x888888FF"
    else if f = 1
        m.fieldLabel.text     = "Username:"
        m.keyboard.text       = m.userText
        m.xtHostDisplay.color = "0x888888FF"
        m.xtUserDisplay.color = "0xFFFFFFFF"
        m.xtPassDisplay.color = "0x888888FF"
    else
        m.fieldLabel.text     = "Password:"
        m.keyboard.text       = m.passText
        m.xtHostDisplay.color = "0x888888FF"
        m.xtUserDisplay.color = "0x888888FF"
        m.xtPassDisplay.color = "0xFFFFFFFF"
    end if
end sub

function buildXtreamUrl() as String
    host = myTrimAS(m.hostText)
    user = myTrimAS(m.userText)
    pass = myTrimAS(m.passText)
    if host = "" or user = "" or pass = "" then return ""
    if Right(host, 1) = "/" then host = Left(host, Len(host) - 1)
    return host + "/get.php?username=" + user + "&password=" + pass + "&type=m3u_plus&output=ts"
end function

sub loadSavedSources()
    keys = m.reg.GetKeyList()
    gc = CreateObject("RoSGNode", "ContentNode")
    if keys <> invalid
        for each k in keys
            raw  = m.reg.Read(k)
            if raw <> invalid and raw <> ""
                item = gc.createChild("ContentNode")
                item.title = raw
                item._key  = k
            end if
        end for
    end if
    m.savedList.content = gc
end sub

sub doSave()
    m.msgLabel.text = ""
    finalUrl = ""

    if m.tabIdx = 0
        finalUrl = myTrimAS(m.urlText)
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

    dt     = CreateObject("roDateTime")
    newKey = "src_" + dt.AsSeconds().ToStr()
    m.reg.Write(newKey, finalUrl)
    m.reg.Flush()

    m.lastSavedUrl = finalUrl
    m.didSave      = true
    m.msgLabel.text = "Saved!  Press Back to close or choose below"
    loadSavedSources()

    m.urlText  = ""
    m.hostText = ""
    m.userText = ""
    m.passText = ""
    m.urlDisplay.text    = ""
    m.xtHostDisplay.text = ""
    m.xtUserDisplay.text = ""
    m.xtPassDisplay.text = ""
    m.keyboard.text = ""

    if m.savedList.content <> invalid and m.savedList.content.getChildCount() > 0
        m.focusArea = "list"
        m.savedList.setFocus(true)
        highlightFocus()
    end if
end sub

sub doDelete()
    if m.savedList.content = invalid then return
    idx  = m.savedList.itemFocused
    item = m.savedList.content.getChild(idx)
    if item = invalid then return

    raw  = item.title
    regKey = item._key
    if regKey <> invalid and regKey <> ""
        m.reg.Delete(regKey)
    else
        keys = m.reg.GetKeyList()
        if keys <> invalid
            for each k in keys
                if m.reg.Read(k) = raw
                    m.reg.Delete(k)
                    exit for
                end if
            end for
        end if
    end if
    m.reg.Flush()

    m.msgLabel.text = "Deleted."
    loadSavedSources()
end sub

sub closeWithResult()
    if m.didSave
        m.didSave = false
        dt = CreateObject("roDateTime")
        m.top.result = { type: "saved", url: m.lastSavedUrl, _ts: dt.AsSeconds() }
    else
        m.top.closed = true
    end if
end sub

sub highlightFocus()
    m.btnSave.color   = "0x4A9FFFFF"
    m.btnDelete.color = "0xFF6666FF"
    m.btnCancel.color = "0x888888FF"
    if m.focusArea = "save"
        m.btnSave.color   = "0xFFFFFFFF"
    else if m.focusArea = "delete"
        m.btnDelete.color = "0xFFAAAAFF"
    else if m.focusArea = "cancel"
        m.btnCancel.color = "0xFFFFFFFF"
    end if
end sub

function myTrimAS(str as String) as String
    if str = invalid then return ""
    start  = 1
    endPos = Len(str)
    while start <= endPos and (Mid(str, start, 1) = " " or Mid(str, start, 1) = chr(13) or Mid(str, start, 1) = chr(10) or Mid(str, start, 1) = chr(9))
        start = start + 1
    end while
    while endPos >= start and (Mid(str, endPos, 1) = " " or Mid(str, endPos, 1) = chr(13) or Mid(str, endPos, 1) = chr(10) or Mid(str, endPos, 1) = chr(9))
        endPos = endPos - 1
    end while
    if start > endPos then return ""
    return Mid(str, start, endPos - start + 1)
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back"
        closeWithResult()
        return true
    end if

    if m.focusArea = "keyboard"
        if key = "rewind" or key = "rev"
            if m.tabIdx = 1 then switchTab(0)
            return true
        end if
        if key = "fastForward" or key = "fwd"
            if m.tabIdx = 0 then switchTab(1)
            return true
        end if

        if key = "play"
            if m.tabIdx = 0
                doSave()
            else
                nextF = m.xtField + 1
                if nextF > 2 then nextF = 0
                setXtField(nextF)
                m.keyboard.setFocus(true)
            end if
            return true
        end if

        if key = "ok"
            doSave()
            return true
        end if

        if key = "down"
            if m.savedList.content <> invalid and m.savedList.content.getChildCount() > 0
                m.focusArea = "list"
                m.savedList.setFocus(true)
            else
                m.focusArea = "save"
                highlightFocus()
            end if
            return true
        end if

        if key = "pause"
            m.focusArea = "save"
            highlightFocus()
            return true
        end if

        return false
    end if

    if m.focusArea = "list"
        if key = "up" and m.savedList.itemFocused = 0
            m.focusArea = "keyboard"
            m.keyboard.setFocus(true)
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
                    m.urlText         = item.title
                    m.urlDisplay.text = item.title
                else
                    m.hostText            = item.title
                    m.xtHostDisplay.text  = item.title
                end if
                m.keyboard.text = item.title
                m.focusArea = "keyboard"
                m.keyboard.setFocus(true)
                highlightFocus()
            end if
            return true
        end if
        return false
    end if

    if m.focusArea = "save" or m.focusArea = "delete" or m.focusArea = "cancel"
        if key = "left"
            if m.focusArea = "delete"       then m.focusArea = "save"
            else if m.focusArea = "cancel"  then m.focusArea = "delete"
            highlightFocus()
            return true
        end if
        if key = "right"
            if m.focusArea = "save"         then m.focusArea = "delete"
            else if m.focusArea = "delete"  then m.focusArea = "cancel"
            highlightFocus()
            return true
        end if
        if key = "up"
            if m.savedList.content <> invalid and m.savedList.content.getChildCount() > 0
                m.focusArea = "list"
                m.savedList.setFocus(true)
            else
                m.focusArea = "keyboard"
                m.keyboard.setFocus(true)
            end if
            highlightFocus()
            return true
        end if
        if key = "pause"
            m.focusArea = "keyboard"
            m.keyboard.setFocus(true)
            highlightFocus()
            return true
        end if
        if key = "ok"
            if m.focusArea = "save"
                doSave()
            else if m.focusArea = "delete"
                doDelete()
            else if m.focusArea = "cancel"
                closeWithResult()
            end if
            return true
        end if
        return true
    end if

    return false
end function
