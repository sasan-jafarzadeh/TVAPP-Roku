' ─────────────────────────────────────────────────────────────────────────────
' Helpers
' ─────────────────────────────────────────────────────────────────────────────

function intToStr(n as Integer) as String
    s = Stri(n)
    r = ""
    i = 1
    while i <= Len(s)
        c = Mid(s, i, 1)
        if c <> " " then r = r + c
        i = i + 1
    end while
    return r
end function

function safeFirst(s as String) as String
    if Len(s) = 0 then return "T"
    return UCase(Left(s, 1))
end function

function getStreamFmt(url as String) as String
    u = LCase(url)
    if Instr(1, u, ".m3u8") > 0   then return "hls"
    if Instr(1, u, "/hls/")  > 0  then return "hls"
    if Instr(1, u, "/live/") > 0  then return "hls"
    if Instr(1, u, "presstv")   > 0 then return "hls"
    if Instr(1, u, "irib.ir")   > 0 then return "hls"
    if Instr(1, u, "telewebion") > 0 then return "hls"
    if Instr(1, u, "persiana.live") > 0 then return "hls"
    if Instr(1, u, "alalam")    > 0 then return "hls"
    if Instr(1, u, ".mpd")  > 0 then return "dash"
    if Instr(1, u, ".mp4")  > 0 then return "mp4"
    ' Unknown – flag as uncertain instead of silently claiming HLS
    return "hls?"
end function

function mkHdr(ua as String, ref as String, org as String) as Object
    h = {}
    h["User-Agent"] = ua
    h["Accept"]     = "*/*"
    if ref <> "" then h["Referer"] = ref
    if org <> "" then h["Origin"]  = org
    return h
end function

function uaBrowser() as String
    return "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36"
end function

function uaVLC() as String
    return "VLC/3.0.18 LibVLC/3.0.18"
end function

function uaRoku() as String
    return "Roku/DVP-12.0 (Roku/DVP-12.0)"
end function

function getHdrVariants(url as String) as Object
    u = LCase(url)
    v = []
    if Instr(1, u, "telewebion") > 0 or Instr(1, u, "hls2.xyz") > 0 or Instr(1, u, "daioncdn") > 0
        v.Push(mkHdr(uaBrowser(), "https://telewebion.com/", "https://telewebion.com"))
        v.Push(mkHdr(uaBrowser(), "https://www.irib.ir/", ""))
        v.Push(mkHdr(uaVLC(), "", ""))
        v.Push(mkHdr(uaRoku(), "", ""))
        return v
    end if
    if Instr(1, u, "workers.dev") > 0 or Instr(1, u, "iranlive") > 0
        v.Push(mkHdr(uaBrowser(), "https://telewebion.com/", "https://telewebion.com"))
        v.Push(mkHdr(uaBrowser(), "", ""))
        v.Push(mkHdr(uaRoku(), "", ""))
        return v
    end if
    if Instr(1, u, "irib.ir") > 0
        v.Push(mkHdr(uaBrowser(), "https://www.irib.ir/", ""))
        v.Push(mkHdr(uaBrowser(), "https://telewebion.com/", "https://telewebion.com"))
        v.Push(mkHdr(uaVLC(), "", ""))
        v.Push(mkHdr(uaRoku(), "", ""))
        return v
    end if
    if Instr(1, u, "presstv") > 0
        v.Push(mkHdr(uaBrowser(), "https://www.presstv.ir/", ""))
        v.Push(mkHdr(uaBrowser(), "", ""))
        v.Push(mkHdr(uaVLC(), "", ""))
        return v
    end if
    if Instr(1, u, "persiana.live") > 0
        v.Push(mkHdr(uaBrowser(), "https://persiana.live/", "https://persiana.live"))
        v.Push(mkHdr(uaBrowser(), "", ""))
        v.Push(mkHdr(uaVLC(), "", ""))
        return v
    end if
    v.Push(mkHdr(uaBrowser(), "", ""))
    v.Push(mkHdr(uaVLC(), "", ""))
    v.Push(mkHdr(uaRoku(), "", ""))
    return v
end function

' ─────────────────────────────────────────────────────────────────────────────
' init
' ─────────────────────────────────────────────────────────────────────────────

sub init()
    ' Core UI refs
    m.video            = m.top.findNode("myVideo")
    m.groupList        = m.top.findNode("groupList")
    m.channelList      = m.top.findNode("channelList")
    m.hintLabel        = m.top.findNode("hintLabel")
    m.errorLabel       = m.top.findNode("errorLabel")
    m.channelHeader    = m.top.findNode("channelHeader")
    m.channelCount     = m.top.findNode("channelCount")
    m.emptyLabel       = m.top.findNode("emptyLabel")
    m.emptyHint        = m.top.findNode("emptyHint")
    m.kb               = m.top.findNode("SearchKeyboard")
    m.searchOverlay    = m.top.findNode("searchOverlay")
    m.searchBox        = m.top.findNode("searchBox")
    m.searchTitle      = m.top.findNode("searchTitle")
    m.spinner          = m.top.findNode("spinner")
    m.loadingLabel     = m.top.findNode("loadingLabel")
    m.watchdog         = m.top.findNode("watchdogTimer")

    ' Detail panel
    m.bigLogoImg       = m.top.findNode("bigLogoImg")
    m.bigLogoFallback  = m.top.findNode("bigLogoFallback")
    m.detailTitle      = m.top.findNode("detailTitle")
    m.detailGroup      = m.top.findNode("detailGroup")
    m.epgNowTitle      = m.top.findNode("epgNowTitle")
    m.qualityLabel     = m.top.findNode("qualityLabel")
    m.liveIndicator    = m.top.findNode("liveIndicator")

    ' Now-playing mini bar
    m.nowPlayingBar    = m.top.findNode("nowPlayingBar")
    m.nowPlayingTitle  = m.top.findNode("nowPlayingTitle")
    m.nowPlayingStatus = m.top.findNode("nowPlayingStatus")

    ' Buffer overlay
    m.bufferOverlay    = m.top.findNode("bufferOverlay")
    m.bufferSpinner    = m.top.findNode("bufferSpinner")
    m.bufferTitle      = m.top.findNode("bufferTitle")
    m.bufferStatus     = m.top.findNode("bufferStatus")
    m.retryDots        = m.top.findNode("retryDots")
    m.bufferTimer      = m.top.findNode("bufferTimer")
    m.retryTimer       = m.top.findNode("retryTimer")

    ' Info overlay (shown on playback start / OK press)
    m.infoOverlay      = m.top.findNode("infoOverlay")
    m.infoAccentLine   = m.top.findNode("infoAccentLine")
    m.infoLogoBox      = m.top.findNode("infoLogoBox")
    m.infoLogoImg      = m.top.findNode("infoLogoImg")
    m.infoLogoFallback = m.top.findNode("infoLogoFallback")
    m.infoTitle        = m.top.findNode("infoTitle")
    m.infoCategory     = m.top.findNode("infoCategory")
    m.liveBadge        = m.top.findNode("liveBadge")
    m.liveBadgeText    = m.top.findNode("liveBadgeText")
    m.skipHint         = m.top.findNode("skipHint")
    m.infoTimer        = m.top.findNode("infoTimer")

    ' Clock
    m.clockLabel       = m.top.findNode("clockLabel")
    m.clockTimer       = m.top.findNode("clockTimer")

    ' Add-source button
    m.addSrcBtn        = m.top.findNode("addSrcBtn")
    m.addSrcBtnLabel   = m.top.findNode("addSrcBtnLabel")

    ' State vars
    m.allGroups         = invalid
    m.currentGroup      = 0
    m.currentChannelIdx = 0
    m.retryUrl          = ""
    m.retryTitle        = ""
    m.retryLogo         = ""
    m.retryPlan         = invalid
    m.retryPlanIdx      = 0
    m.userStopped       = false
    m.addSourceOverlay  = invalid
    m.addSrcFocused     = false
    m.isSearchMode      = false
    m.retryNeeded       = false

    ' Favorites (persisted)
    m.favRegistry = CreateObject("roRegistrySection", "IPTVFavorites")
    m.favorites   = {}
    for each k in m.favRegistry.GetKeyList()
        m.favorites[k] = true
    end for

    ' Observers
    m.groupList.observeField("itemFocused",   "onGroupFocused")
    m.groupList.observeField("itemSelected",  "onGroupSelected")
    m.channelList.observeField("itemFocused", "onChannelFocused")
    m.channelList.observeField("itemSelected","onChannelSelected")
    m.kb.observeField("text",                 "onSearch")
    m.video.observeField("state",             "onVideoStateChange")
    m.infoTimer.observeField("fire",          "onInfoTimerFired")
    m.bufferTimer.observeField("fire",        "onBufferTimeout")
    m.retryTimer.observeField("fire",         "onRetryTimerFired")
    m.watchdog.observeField("fire",           "onWatchdogFired")
    m.clockTimer.observeField("fire",         "onClockTick")

    ' Start parser
    showHint("Loading playlist...")
    m.parser = createObject("RoSGNode", "M3UParser")
    m.parser.observeField("content", "onM3UFinished")
    m.parser.observeField("state",   "onParserState")
    m.parser.control = "RUN"
    m.watchdog.duration = 60
    m.watchdog.control  = "start"

    m.clockTimer.control = "start"
    onClockTick()
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Status label helpers – clearly separate hint vs error
' ─────────────────────────────────────────────────────────────────────────────

sub showHint(msg as String)
    m.hintLabel.text      = msg
    m.hintLabel.visible   = true
    m.errorLabel.visible  = false
end sub

sub showError(msg as String)
    m.errorLabel.text     = msg
    m.errorLabel.visible  = true
    m.hintLabel.visible   = false
end sub

sub clearStatus()
    m.hintLabel.visible  = false
    m.errorLabel.visible = false
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Clock
' ─────────────────────────────────────────────────────────────────────────────

sub onClockTick()
    ' Reuse a single roDateTime; Mark() refreshes it to the current time.
    if m.clockDt = invalid then m.clockDt = CreateObject("roDateTime")
    m.clockDt.Mark()
    m.clockDt.ToLocalTime()
    dt   = m.clockDt
    h    = dt.GetHours()
    mn   = dt.GetMinutes()
    ampm = "AM"
    if h >= 12 then ampm = "PM"
    if h > 12  then h = h - 12
    if h = 0   then h = 12
    ms = intToStr(mn)
    if Len(ms) < 2 then ms = "0" + ms
    m.clockLabel.text = intToStr(h) + ":" + ms + " " + ampm
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Parser callbacks
' ─────────────────────────────────────────────────────────────────────────────

sub onParserState()
    st = m.parser.state
    if st = "RUN"
        showHint("Fetching playlist...")
        m.spinner.visible = true
    else if st = "DONE" or st = "STOP"
        m.spinner.visible = false
    end if
end sub

sub onWatchdogFired()
    if m.allGroups = invalid
        m.spinner.visible      = false
        m.loadingLabel.visible = false
        showError("Timeout loading playlist. Press OK to retry.")
        m.retryNeeded = true
        ' Make sure REW/AddSource is reachable even without any list focus
        m.groupList.visible   = false
        m.channelList.visible = false
        m.emptyLabel.text     = "No channels loaded"
        m.emptyLabel.visible  = true
        m.emptyHint.visible   = true
    end if
end sub

sub onM3UFinished()
    m.watchdog.control     = "stop"
    m.spinner.visible      = false
    m.loadingLabel.visible = false

    cnt = 0
    if m.parser.content <> invalid then cnt = m.parser.content.getChildCount()

    if cnt = 0
        showError("Playlist empty or unreachable.")
        ' Show empty state so user has clear path to AddSource
        m.groupList.visible   = false
        m.channelList.visible = false
        m.emptyLabel.text     = "No channels found"
        m.emptyLabel.visible  = true
        m.emptyHint.visible   = true
        ' Safe to open AddSource via REW even with no focus on a list
        return
    end if

    m.allGroups = m.parser.content

    ' Assign sequential channel numbers & apply favorites
    chNum = 1
    g = 0
    while g < m.allGroups.getChildCount()
        gNode = m.allGroups.getChild(g)
        if gNode <> invalid
            c = 0
            while c < gNode.getChildCount()
                ch = gNode.getChild(c)
                if ch <> invalid
                    ch.chNum = chNum
                    chNum    = chNum + 1
                    if ch.url <> invalid
                        ch.isFav = m.favorites.DoesExist(ch.url)
                    end if
                end if
                c = c + 1
            end while
        end if
        g = g + 1
    end while

    buildFavoritesGroup()
    rebuildGroupList()
    loadGroup(0)

    m.emptyLabel.visible  = false
    m.emptyHint.visible   = false
    m.groupList.visible   = true
    m.channelList.visible = true
    m.groupList.setFocus(true)

    total = 0
    g2 = 0
    while g2 < m.allGroups.getChildCount()
        gn = m.allGroups.getChild(g2)
        if gn <> invalid then total = total + gn.getChildCount()
        g2 = g2 + 1
    end while
    showHint("OK:Play  UP/DN:Ch  *:Search  REW:Source  Pause:Fav   " + intToStr(total) + " ch")
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Group / channel list management
' ─────────────────────────────────────────────────────────────────────────────

sub rebuildGroupList()
    if m.allGroups = invalid then return
    gc = createObject("RoSGNode", "ContentNode")
    i = 0
    while i < m.allGroups.getChildCount()
        g    = m.allGroups.getChild(i)
        item = gc.createChild("ContentNode")
        item.title = g.title + " (" + intToStr(g.getChildCount()) + ")"
        i = i + 1
    end while
    m.groupList.content = gc
end sub

sub loadGroup(idx as Integer)
    if m.allGroups = invalid then return
    gNode = m.allGroups.getChild(idx)
    if gNode = invalid then return
    m.currentGroup       = idx
    m.isSearchMode       = false
    m.channelHeader.text = gNode.title
    m.channelCount.text  = intToStr(gNode.getChildCount()) + " ch"
    m.channelList.content = gNode
    updateDetailPanel(gNode.getChild(0))
end sub

sub onGroupFocused()
    loadGroup(m.groupList.itemFocused)
end sub

sub onGroupSelected()
    loadGroup(m.groupList.itemSelected)
    m.channelList.setFocus(true)
end sub

sub onChannelFocused()
    idx  = m.channelList.itemFocused
    item = m.channelList.content.getChild(idx)
    updateDetailPanel(item)
end sub

sub onChannelSelected()
    idx  = m.channelList.itemSelected
    item = m.channelList.content.getChild(idx)
    if item = invalid then return
    m.currentChannelIdx = idx
    if item.url = invalid or item.url = "" then return
    logo = ""
    if item.hdPosterUrl <> invalid then logo = item.hdPosterUrl
    playUrl(item.url, item.title, logo)
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Detail panel
' ─────────────────────────────────────────────────────────────────────────────

sub updateDetailPanel(item as Object)
    if item = invalid  then return
    if item.title = invalid then return

    m.detailTitle.text = item.title
    m.detailGroup.text = m.channelHeader.text
    m.epgNowTitle.text = "Live Stream"

    ' Quality badge – normalise "hls?" to "HLS" so the user never sees a "?"
    if item.url <> invalid and item.url <> ""
        fmt = getStreamFmt(item.url)
        if fmt = "hls?" then fmt = "hls"
        m.qualityLabel.text = UCase(fmt)
    else
        m.qualityLabel.text = "?"
    end if

    ' Logo with proper visibility toggling
    logo = ""
    if item.hdPosterUrl <> invalid then logo = item.hdPosterUrl
    if logo <> ""
        m.bigLogoImg.uri          = logo
        m.bigLogoImg.visible      = true
        m.bigLogoFallback.visible = false
    else
        m.bigLogoImg.uri          = ""
        m.bigLogoImg.visible      = false
        m.bigLogoFallback.visible = true
        m.bigLogoFallback.text    = safeFirst(item.title)
    end if
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Favorites
' ─────────────────────────────────────────────────────────────────────────────

sub toggleFavorite()
    if m.channelList.content = invalid then return
    idx  = m.channelList.itemFocused
    item = m.channelList.content.getChild(idx)
    if item = invalid then return
    if item.url = invalid or item.url = "" then return
    key = item.url
    if m.favorites.DoesExist(key)
        m.favorites.Delete(key)
        m.favRegistry.Delete(key)
        item.isFav = false
        m.infoCategory.text = "Removed from Favorites"
    else
        m.favorites[key] = true
        m.favRegistry.Write(key, item.title)
        item.isFav = true
        m.infoCategory.text = "Added to Favorites ★"
    end if
    m.favRegistry.Flush()
    m.infoTitle.text = item.title
    showInfoOverlay()
    buildFavoritesGroup()
    savedGroupIdx   = m.currentGroup
    savedChannelIdx = idx
    rebuildGroupList()
    m.groupList.jumpToItem   = savedGroupIdx
    m.channelList.jumpToItem = savedChannelIdx
end sub

sub buildFavoritesGroup()
    if m.allGroups = invalid then return
    favNode = invalid
    i = 0
    while i < m.allGroups.getChildCount()
        g = m.allGroups.getChild(i)
        if g <> invalid and g.title = "* Favorites" then favNode = g
        i = i + 1
    end while
    if favNode = invalid
        favNode       = createObject("RoSGNode", "ContentNode")
        favNode.title = "* Favorites"
        m.allGroups.insertChild(favNode, 0)
    end if
    while favNode.getChildCount() > 0
        favNode.removeChild(favNode.getChild(0))
    end while
    g = 0
    while g < m.allGroups.getChildCount()
        gNode = m.allGroups.getChild(g)
        if gNode <> invalid and gNode.title <> "* Favorites"
            c = 0
            while c < gNode.getChildCount()
                ch = gNode.getChild(c)
                if ch <> invalid and ch.url <> invalid
                    if m.favorites.DoesExist(ch.url)
                        ' Rebuild the node manually instead of clone() to ensure
                        ' dynamic fields (url, isFav, chNum, hdPosterUrl) are preserved.
                        copy = favNode.createChild("ContentNode")
                        copy.title       = ch.title
                        copy.url         = ch.url
                        copy.isFav       = true
                        copy.chNum       = ch.chNum
                        if ch.hdPosterUrl <> invalid then copy.hdPosterUrl = ch.hdPosterUrl
                    end if
                end if
                c = c + 1
            end while
        end if
        g = g + 1
    end while
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Search
' ─────────────────────────────────────────────────────────────────────────────

sub onSearch()
    if m.allGroups = invalid then return
    q = LCase(m.kb.text)
    if q = ""
        if not m.isSearchMode then loadGroup(m.currentGroup)
        return
    end if
    m.isSearchMode = true
    filtered = createObject("RoSGNode", "ContentNode")
    g = 0
    while g < m.allGroups.getChildCount()
        gNode = m.allGroups.getChild(g)
        if gNode <> invalid and gNode.title <> "* Favorites"
            c = 0
            while c < gNode.getChildCount()
                ch = gNode.getChild(c)
                if ch <> invalid and ch.title <> invalid
                    if Instr(1, LCase(ch.title), q) > 0
                        filtered.appendChild(ch)
                    end if
                end if
                c = c + 1
            end while
        end if
        g = g + 1
    end while
    m.channelHeader.text  = "Search: " + m.kb.text
    m.channelCount.text   = intToStr(filtered.getChildCount()) + " ch"
    m.channelList.content = filtered
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Playback
' ─────────────────────────────────────────────────────────────────────────────

sub skipChannel(direction as String)
    if m.channelList.content = invalid then return
    total = m.channelList.content.getChildCount()
    if total = 0 then return
    idx = m.currentChannelIdx
    if direction = "up"
        idx = idx - 1
        if idx < 0 then idx = total - 1
    else
        idx = idx + 1
        if idx >= total then idx = 0
    end if
    m.currentChannelIdx      = idx
    m.channelList.jumpToItem = idx
    item = m.channelList.content.getChild(idx)
    if item = invalid then return
    if item.url = invalid or item.url = "" then return
    logo = ""
    if item.hdPosterUrl <> invalid then logo = item.hdPosterUrl
    ' Stop current stream cleanly before starting next
    m.video.control = "stop"
    m.video.content = invalid
    playUrl(item.url, item.title, logo)
end sub

sub playUrl(url as String, title as String, logo as String)
    m.retryTimer.control  = "stop"
    m.bufferTimer.control = "stop"
    m.userStopped         = false
    m.retryInFlight       = false
    m.retryUrl            = url
    m.retryTitle          = title
    m.retryLogo           = logo

    detectedFmt = getStreamFmt(url)
    ' Normalize hls? → hls for playback
    if detectedFmt = "hls?" then detectedFmt = "hls"
    hdrs    = getHdrVariants(url)
    allFmts = ["hls", "dash", "ism", "mp4"]

    plan = []
    i = 0
    while i < hdrs.Count()
        s         = {}
        s.fmt     = detectedFmt
        s.headers = hdrs[i]
        plan.Push(s)
        i = i + 1
    end while
    i = 0
    while i < allFmts.Count()
        if allFmts[i] <> detectedFmt
            s         = {}
            s.fmt     = allFmts[i]
            s.headers = hdrs[0]
            plan.Push(s)
        end if
        i = i + 1
    end while

    m.retryPlan    = plan
    m.retryPlanIdx = 0

    doPlay(0)

    m.video.visible       = true
    m.groupList.visible   = false
    m.channelList.visible = false
    m.video.setFocus(true)

    showBufferOverlay(title)
    m.bufferTimer.control = "start"

    m.nowPlayingTitle.text     = title
    m.nowPlayingBar.visible    = true
    m.nowPlayingTitle.visible  = true
    m.nowPlayingStatus.visible = true
end sub

sub doPlay(idx as Integer)
    if m.retryPlan = invalid then return
    if idx >= m.retryPlan.Count() then return
    planStep       = m.retryPlan[idx]
    m.retryPlanIdx = idx
    vi                         = createObject("RoSGNode", "ContentNode")
    vi.title                   = m.retryTitle
    vi.url                     = m.retryUrl
    vi.streamformat            = planStep.fmt
    vi.live                    = true
    vi.SuggestedMaxBitrate     = 20000
    vi.SuggestedMinBitrate     = 0
    vi.SuggestedBufferDuration = 10
    vi.HttpHeaders             = planStep.headers
    m.video.control = "stop"
    m.video.content = invalid
    m.video.content = vi
    m.video.control = "play"
end sub

sub stopPlayback()
    m.userStopped         = true
    m.retryInFlight       = false
    m.bufferTimer.control = "stop"
    m.retryTimer.control  = "stop"
    m.retryUrl            = ""
    m.retryPlan           = invalid
    m.retryPlanIdx        = 0
    hideBufferOverlay()
    hideInfoOverlay()
    m.video.control       = "stop"
    m.video.content       = invalid
    m.video.visible       = false
    m.groupList.visible   = true
    m.channelList.visible = true
    m.channelList.setFocus(true)
    setAddSrcFocus(false)
    m.nowPlayingBar.visible    = false
    m.nowPlayingTitle.visible  = false
    m.nowPlayingStatus.visible = false
    showHint("OK:Play  UP/DN:Ch  *:Search  REW:Source  Pause:Fav")
end sub

sub showPlayError()
    showError("Stream unavailable. Try another channel.")
    stopPlayback()
end sub

sub onVideoStateChange()
    if m.userStopped then return
    if m.retryUrl = "" then return
    state = m.video.state
    if state = "playing"
        m.bufferTimer.control = "stop"
        m.retryInFlight       = false
        hideBufferOverlay()
        showHint("OK:Info  UP/DN:Ch  Back:Stop")
        showInfoOverlay()
    else if state = "buffering"
        m.bufferStatus.text = "Buffering..."
        if not m.bufferOverlay.visible then showBufferOverlay(m.retryTitle)
    else if state = "error"
        m.bufferTimer.control = "stop"
        if m.retryPlan <> invalid
            nextIdx = m.retryPlanIdx + 1
            if nextIdx < m.retryPlan.Count()
                ' Guard: only schedule a retry if one is not already pending.
                ' Duplicate error events (e.g. buffering→error→error) must not
                ' double-advance the plan index.
                if m.retryInFlight then return
                m.retryInFlight = true
                total = m.retryPlan.Count()
                dots  = ""
                d = 0
                while d < total
                    if d <= nextIdx then dots = dots + "|" else dots = dots + "-"
                    d = d + 1
                end while
                m.retryDots.text    = dots
                m.retryDots.visible = true
                m.bufferStatus.text = "Retry " + intToStr(nextIdx + 1) + "/" + intToStr(total) + "..."
                m.retryPlanIdx = nextIdx
                showBufferOverlay(m.retryTitle)
                m.retryTimer.control = "stop"
                m.retryTimer.control = "start"
                return
            end if
        end if
        showPlayError()
    else if state = "finished"
        m.bufferTimer.control = "stop"
        m.retryInFlight       = false
        hideBufferOverlay()
        stopPlayback()
    end if
end sub

sub onBufferTimeout()
    m.bufferTimer.control = "stop"
    if m.retryPlan <> invalid
        nextIdx = m.retryPlanIdx + 1
        if nextIdx < m.retryPlan.Count()
            m.retryPlanIdx = nextIdx
            m.bufferStatus.text = "Timeout – retry " + intToStr(nextIdx + 1) + "/" + intToStr(m.retryPlan.Count()) + "..."
            doPlay(nextIdx)
            return
        end if
    end if
    hideBufferOverlay()
    showError("Stream unavailable. Try another channel.")
    stopPlayback()
end sub

sub onRetryTimerFired()
    if m.retryUrl = "" then return
    if m.retryPlan = invalid then return
    m.retryInFlight = false   ' timer has fired; slot is now free for the next error event
    ' Guard: retryPlanIdx was already incremented in onVideoStateChange;
    ' do NOT increment again here to avoid double-advance on duplicate fire.
    if m.retryPlanIdx >= m.retryPlan.Count()
        showPlayError()
        return
    end if
    doPlay(m.retryPlanIdx)
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Overlay helpers
' ─────────────────────────────────────────────────────────────────────────────

sub showBufferOverlay(title as String)
    m.bufferTitle.text      = title
    m.bufferStatus.text     = "Connecting..."
    m.retryDots.text        = ""
    m.retryDots.visible     = false
    m.bufferOverlay.visible = true
    m.bufferSpinner.visible = true
    m.bufferTitle.visible   = true
    m.bufferStatus.visible  = true
end sub

sub hideBufferOverlay()
    m.bufferOverlay.visible = false
    m.bufferSpinner.visible = false
    m.bufferTitle.visible   = false
    m.bufferStatus.visible  = false
    m.retryDots.visible     = false
end sub

sub showInfoOverlay()
    logo = m.retryLogo
    if logo <> ""
        m.infoLogoImg.uri          = logo
        m.infoLogoImg.visible      = true
        m.infoLogoFallback.visible = false
    else
        m.infoLogoImg.uri          = ""
        m.infoLogoImg.visible      = false
        m.infoLogoFallback.visible = true
        m.infoLogoFallback.text    = safeFirst(m.retryTitle)
    end if
    m.infoLogoBox.visible    = true
    m.infoTitle.text         = m.retryTitle
    m.infoOverlay.visible    = true
    m.infoAccentLine.visible = true
    m.infoTitle.visible      = true
    m.infoCategory.visible   = true
    m.liveBadge.visible      = true
    m.liveBadgeText.visible  = true
    m.skipHint.visible       = true
    m.infoTimer.control      = "start"
end sub

sub hideInfoOverlay()
    m.infoOverlay.visible    = false
    m.infoAccentLine.visible = false
    m.infoTitle.visible      = false
    m.infoCategory.visible   = false
    m.infoLogoBox.visible    = false
    m.infoLogoImg.visible    = false
    m.infoLogoFallback.visible = false
    m.liveBadge.visible      = false
    m.liveBadgeText.visible  = false
    m.skipHint.visible       = false
end sub

sub onInfoTimerFired()
    hideInfoOverlay()
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Add Source overlay
' ─────────────────────────────────────────────────────────────────────────────

sub openAddSource()
    if m.addSourceOverlay <> invalid
        m.top.removeChild(m.addSourceOverlay)
        m.addSourceOverlay = invalid
    end if
    overlay = m.top.createChild("AddSourceScene")
    if overlay = invalid
        print "DEBUG: AddSourceScene creation failed!"
        return
    end if
    overlay.closed = false
    overlay.observeField("result", "onAddSourceResult")
    overlay.observeField("closed", "onAddSourceClosed")
    m.addSourceOverlay = overlay
end sub

sub onAddSourceResult()
    if m.addSourceOverlay = invalid then return
    res = m.addSourceOverlay.result
    if res = invalid then return
    if res.type = "saved"
        closeAddSource()
        reloadPlaylist()
    end if
end sub

sub onAddSourceClosed()
    closeAddSource()
end sub

sub closeAddSource()
    if m.addSourceOverlay = invalid then return
    m.top.removeChild(m.addSourceOverlay)
    m.addSourceOverlay = invalid
    setAddSrcFocus(false)
    ' Return focus to list if available, otherwise nothing (empty state)
    if m.channelList.visible then m.channelList.setFocus(true)
end sub

sub reloadPlaylist()
    if m.parser <> invalid
        m.parser.unobserveField("content")
        m.parser.unobserveField("state")
        m.parser.control = "STOP"
        m.parser = invalid
    end if
    m.allGroups           = invalid
    m.groupList.visible   = false
    m.channelList.visible = false
    m.emptyLabel.visible  = false
    m.emptyHint.visible   = false
    m.spinner.visible     = true
    m.loadingLabel.text   = "Reloading playlist..."
    m.loadingLabel.visible = true
    showHint("Reloading...")
    m.parser = createObject("RoSGNode", "M3UParser")
    m.parser.observeField("content", "onM3UFinished")
    m.parser.observeField("state",   "onParserState")
    m.parser.control    = "RUN"
    m.watchdog.control  = "stop"   ' cancel any in-flight countdown first
    m.watchdog.duration = 60
    m.watchdog.control  = "start"
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Add-source button focus
' ─────────────────────────────────────────────────────────────────────────────

sub setAddSrcFocus(focused as Boolean)
    m.addSrcFocused = focused
    if focused
        m.addSrcBtn.color      = "0x1A3A7AFF"
        m.addSrcBtnLabel.color = "0xFFFFFFFF"
        m.addSrcBtn.setFocus(true)
    else
        m.addSrcBtn.color      = "0x0C1E3CFF"
        m.addSrcBtnLabel.color = "0x4A9FFFFF"
    end if
end sub

' ─────────────────────────────────────────────────────────────────────────────
' Key handler
' ─────────────────────────────────────────────────────────────────────────────

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    ' ── Video playing ──────────────────────────────────────────────────────
    if m.video.visible
        if key = "back"
            stopPlayback()
            return true
        end if
        if key = "up" or key = "down"
            skipChannel(key)
            return true
        end if
        if key = "ok"
            showInfoOverlay()
            return true
        end if
        return false
    end if

    ' ── Search keyboard open ───────────────────────────────────────────────
    if m.kb.visible
        if key = "back"
            m.kb.visible            = false
            m.searchOverlay.visible = false
            m.searchBox.visible     = false
            m.searchTitle.visible   = false
            if m.kb.text = "" then loadGroup(m.currentGroup)
            m.channelList.setFocus(true)
            return true
        end if
        return false
    end if

    ' ── AddSource overlay open: swallow all keys except Back ───────────────
    ' (prevents double-open from REW while overlay is already visible)
    if m.addSourceOverlay <> invalid
        if key = "back"
            closeAddSource()
        end if
        return true
    end if

    ' ── Retry after error ──────────────────────────────────────────────────
    if key = "ok" and m.retryNeeded
        m.retryNeeded = false
        reloadPlaylist()
        return true
    end if

    ' ── OK on empty channel list → open AddSource ─────────────────────────
    if key = "ok" and m.channelList.hasFocus()
        if m.channelList.content = invalid or m.channelList.content.getChildCount() = 0
            openAddSource()
            return true
        end if
    end if

    ' ── AddSource button focused ───────────────────────────────────────────
    if m.addSrcFocused
        if key = "ok"
            openAddSource()
            return true
        end if
        if key = "left" or key = "back" or key = "up" or key = "down"
            setAddSrcFocus(false)
            m.channelList.setFocus(true)
            return true
        end if
        return true
    end if

    ' ── Global shortcuts ───────────────────────────────────────────────────
    if key = "options"
        m.kb.text               = ""
        m.searchOverlay.visible = true
        m.searchBox.visible     = true
        m.searchTitle.visible   = true
        m.kb.visible            = true
        m.kb.setFocus(true)
        return true
    end if

    if key = "rewind" or key = "rev"
        openAddSource()
        return true
    end if

    if key = "play" or key = "pause"
        if m.channelList.hasFocus() and m.channelList.content <> invalid
            toggleFavorite()
            return true
        end if
    end if

    ' ── Panel navigation ──────────────────────────────────────────────────
    if key = "left" and not m.groupList.hasFocus()
        m.groupList.setFocus(true)
        return true
    end if

    if key = "right"
        if m.channelList.hasFocus()
            setAddSrcFocus(true)
            return true
        end if
        if m.channelList.content <> invalid and m.channelList.content.getChildCount() > 0
            m.channelList.setFocus(true)
        else
            setAddSrcFocus(true)
        end if
        return true
    end if

    return false
end function
