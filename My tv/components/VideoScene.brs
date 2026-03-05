sub init()
    ' مقداردهی نودها
    m.video = m.top.findNode("myVideo")
    m.categoryList = m.top.findNode("categoryList")
    m.channelList = m.top.findNode("channelList")
    m.listBG = m.top.findNode("listBackground")
    m.infoBar = m.top.findNode("infoBar")
    m.loading = m.top.findNode("loadingIndicator")
    m.splashLayer = m.top.findNode("splashLayer")
    m.menuAnim = m.top.findNode("menuAnim")
    m.fadeSplash = m.top.findNode("fadeSplash")
    m.uiTimer = m.top.findNode("uiTimer")
    
    m.dataByGroup = {}
    m.currentGroupChannels = []

    ' تنظیمات تایمرها
    m.top.findNode("clockTimer").observeField("fire", "updateClock")
    m.top.findNode("clockTimer").control = "start"
    m.uiTimer.observeField("fire", "hideInfo")
    m.fadeSplash.observeField("state", "onSplashFadeFinished")
    updateClock()

    ' ناظرها (Observers)
    m.categoryList.observeField("itemSelected", "onCategorySelected")
    m.channelList.observeField("itemSelected", "onChannelSelected")
    m.video.observeField("state", "onVideoStateChange")
    
    fetchM3U()
end sub

sub updateClock()
    date = CreateObject("roDateTime")
    date.toLocalTime()
    m.top.findNode("clockLabel").text = date.getHours().ToStr() + ":" + String(2, "0").Left(2 - date.getMinutes().ToStr().Len()) + date.getMinutes().ToStr()
end sub

sub fetchM3U()
    m.loading.control = "start"
    url = "https://raw.githubusercontent.com/sasan-jafarzadeh/iptv-cleaner/refs/heads/main/live_list.m3u"
    
    request = CreateObject("roUrlTransfer")
    request.SetUrl(url)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    
    response = request.GetToString()
    if request.GetResponseCode() = 200 and response <> ""
        parseM3U(response)
    else
        showError("Network Error: " + request.GetResponseCode().ToStr())
    end if
end sub

sub parseM3U(data as String)
    lines = data.Split(chr(10))
    regLogo = CreateObject("roRegEx", "tvg-logo=""([^""]+)""", "i")
    regGroup = CreateObject("roRegEx", "group-title=""([^""]+)""", "i")
    
    for i = 0 to lines.Count() - 1
        line = lines[i].Trim()
        if line.Left(7) = "#EXTINF"
            item = { title: "Unknown Channel", logo: "", group: "General", url: "" }
            
            logoMatch = regLogo.Match(line)
            if logoMatch.Count() > 1 then item.logo = logoMatch[1]
            
            groupMatch = regGroup.Match(line)
            if groupMatch.Count() > 1 then item.group = groupMatch[1]
            
            commaPos = line.InstrRev(",")
            if commaPos > 0 then item.title = line.Mid(commaPos + 1).Trim()
            
            for k = i + 1 to i + 3
                if k < lines.Count() and lines[k].Trim() <> "" and lines[k].Left(1) <> "#"
                    item.url = lines[k].Trim()
                    exit for
                end if
            end for
            
            if item.url <> ""
                if m.dataByGroup[item.group] = invalid then m.dataByGroup[item.group] = []
                m.dataByGroup[item.group].Push(item)
            end if
        end if
    end for
    
    catContent = CreateObject("roSGNode", "ContentNode")
    for each g in m.dataByGroup
        child = catContent.CreateChild("ContentNode")
        child.title = g
    end for
    m.categoryList.content = catContent
    
    ' پایان عملیات لودینگ و حذف اسپلش
    m.loading.control = "stop"
    m.fadeSplash.control = "start"
    if m.dataByGroup.Count() > 0 then playChannel(m.dataByGroup.Keys()[0], 0)
end sub

sub playChannel(groupName, index)
    chan = m.dataByGroup[groupName][index]
    videoContent = CreateObject("roSGNode", "ContentNode")
    videoContent.url = chan.url
    videoContent.streamformat = "hls"
    videoContent.live = true
    
    m.top.findNode("channelTitle").text = chan.title
    m.top.findNode("groupTitle").text = groupName
    m.top.findNode("channelLogo").uri = chan.logo
    
    m.video.content = videoContent
    m.video.control = "play"
end sub

sub onCategorySelected()
    groupNames = m.dataByGroup.Keys()
    selectedGroup = groupNames[m.categoryList.itemSelected]
    m.currentGroupChannels = m.dataByGroup[selectedGroup]
    
    chanContent = CreateObject("roSGNode", "ContentNode")
    for each c in m.currentGroupChannels
        child = chanContent.CreateChild("ContentNode")
        child.title = c.title
    end for
    
    m.channelList.content = chanContent
    m.categoryList.visible = false
    m.channelList.visible = true
    m.channelList.setFocus(true)
    m.top.findNode("menuTitle").text = selectedGroup
end sub

sub onChannelSelected()
    groupNames = m.dataByGroup.Keys()
    playChannel(groupNames[m.categoryList.itemSelected], m.channelList.itemSelected)
    closeMenu()
end sub

sub onVideoStateChange()
    if m.video.state = "playing"
        m.infoBar.visible = true
        m.uiTimer.duration = 5
        m.uiTimer.control = "start"
    else if m.video.state = "error"
        showError("Playback Failed")
    end if
end sub

sub showError(msg)
    m.top.findNode("errorMsg").text = msg
    m.top.findNode("errorMsg").visible = true
    m.infoBar.visible = true
end sub

sub hideInfo()
    m.infoBar.visible = false
end sub

sub openMenu()
    m.listBG.visible = true
    m.top.findNode("menuInterp").keyValue = [m.listBG.translation, [0, 0]]
    m.menuAnim.control = "start"
    if m.channelList.visible then m.channelList.setFocus(true) else m.categoryList.setFocus(true)
end sub

sub closeMenu()
    m.top.findNode("menuInterp").keyValue = [m.listBG.translation, [-600, 0]]
    m.menuAnim.control = "start"
    m.video.setFocus(true)
end sub

sub onSplashFadeFinished()
    if m.fadeSplash.state = "stopped" then m.splashLayer.visible = false
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press
        if key = "left"
            openMenu()
            return true
        else if key = "back"
            if m.channelList.visible
                m.channelList.visible = false
                m.categoryList.visible = true
                m.categoryList.setFocus(true)
                m.top.findNode("menuTitle").text = "Categories"
                return true
            else if m.listBG.translation[0] >= 0
                closeMenu()
                return true
            end if
        end if
    end if
    return false
end function