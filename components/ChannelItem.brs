sub init()
    m.rowBg        = m.top.findNode("rowBg")
    m.accentBar    = m.top.findNode("accentBar")
    m.logoImg      = m.top.findNode("logoImg")
    m.logoFallback = m.top.findNode("logoFallback")
    m.titleLabel   = m.top.findNode("titleLabel")
    m.favStar      = m.top.findNode("favStar")
    m.top.observeField("focusPercent", "onFocusChange")
    m.logoImg.observeField("loadStatus", "onLogoLoadStatus")
end sub

sub onContentChange()
    content = m.top.itemContent
    if content = invalid then return

    if content.title <> invalid
        m.titleLabel.text = content.title
    end if

    logo = ""
    if content.hdPosterUrl <> invalid then logo = content.hdPosterUrl
    if logo <> ""
        m.logoImg.uri          = logo
        m.logoImg.visible      = true
        m.logoFallback.visible = false
    else
        m.logoImg.uri          = ""
        m.logoImg.visible      = false
        m.logoFallback.visible = true
        if content.title <> invalid and Len(content.title) > 0
            m.logoFallback.text = UCase(Left(content.title, 1))
        else
            m.logoFallback.text = "TV"
        end if
    end if

    if content.isFav <> invalid and content.isFav = true
        m.favStar.opacity = 1
    else
        m.favStar.opacity = 0
    end if
end sub

sub onLogoLoadStatus()
    if m.logoImg.loadStatus = "failed"
        m.logoImg.uri          = ""
        m.logoImg.visible      = false
        m.logoFallback.visible = true
    end if
end sub

sub onFocusChange()
    f = m.top.focusPercent
    if f > 0.5
        m.rowBg.opacity     = 1
        m.accentBar.opacity = 1
        m.titleLabel.color  = &hFFFFFFFF
    else
        m.rowBg.opacity     = 0
        m.accentBar.opacity = 0
        m.titleLabel.color  = &h8899BBFF
    end if
end sub
