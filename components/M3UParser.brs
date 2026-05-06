sub init()
    m.top.functionName = "runTask"
end sub

function myTrim(str as String) as String
    if str = invalid or str = "" then return ""
    start = 1
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

function getSubCategory(s as String) as String
    if s = invalid or s = "" then return "General"
    lo = LCase(s)
    if Instr(1, lo, "news") > 0 or Instr(1, lo, "haber") > 0 then return "News"
    if Instr(1, lo, "sport") > 0 or Instr(1, lo, "spor") > 0 or Instr(1, lo, "fight") > 0 then return "Sports"
    if Instr(1, lo, "music") > 0 or Instr(1, lo, "muzik") > 0 then return "Music"
    if Instr(1, lo, "movie") > 0 or Instr(1, lo, "film") > 0 or Instr(1, lo, "series") > 0 or Instr(1, lo, "entertainment") > 0 or Instr(1, lo, "classic") > 0 or Instr(1, lo, "comedy") > 0 or Instr(1, lo, "drama") > 0 then return "Entertainment"
    return "General"
end function

function getSubCategoryFromTitle(t as String) as String
    if t = invalid or t = "" then return "General"
    lo = LCase(t)
    if Instr(1, lo, "news") > 0 or Instr(1, lo, "khabar") > 0 or Instr(1, lo, "press") > 0 or Instr(1, lo, "international") > 0 then return "News"
    if Instr(1, lo, "sport") > 0 or Instr(1, lo, "varzesh") > 0 or Instr(1, lo, "fight") > 0 or Instr(1, lo, "fit") > 0 then return "Sports"
    if Instr(1, lo, "music") > 0 or Instr(1, lo, "avang") > 0 or Instr(1, lo, "radio javan") > 0 or Instr(1, lo, "mifa") > 0 or Instr(1, lo, "folk") > 0 or Instr(1, lo, "vibe") > 0 then return "Music"
    if Instr(1, lo, "film") > 0 or Instr(1, lo, "movie") > 0 or Instr(1, lo, "cinema") > 0 or Instr(1, lo, "series") > 0 or Instr(1, lo, "drama") > 0 or Instr(1, lo, "comedy") > 0 then return "Entertainment"
    return "General"
end function

function detectLanguage(title as String, groupRaw as String, url as String) as String
    if title = invalid then title = ""
    if groupRaw = invalid then groupRaw = ""
    if url = invalid then url = ""
    
    tlo = LCase(title)
    glo = LCase(groupRaw)
    ulo = LCase(url)

    if Instr(1, glo, "tr |") > 0 or Instr(1, glo, "|tr|") > 0 or Left(glo, 3) = "tr " then return "Turkish"

    if Instr(1, tlo, "bloomberg ht") > 0 or Instr(1, tlo, "akit") > 0 or Instr(1, tlo, "360 tv") > 0 or Instr(1, tlo, "can tv") > 0 or Instr(1, tlo, "atv") > 0 or Instr(1, tlo, "cnbc-e") > 0 then return "Turkish"
    if Instr(1, ulo, ".tr/") > 0 or Instr(1, ulo, "turknet") > 0 or Instr(1, ulo, "ercdn.net") > 0 or Instr(1, ulo, "turkmedya") > 0 then return "Turkish"

    if Instr(1, ulo, "iptv-org.github.io/iptv/countries/ir") > 0 then return "Persian"

    if Instr(1, ulo, "telewebion.ir") > 0 or Instr(1, ulo, "telewebion.com") > 0 then return "Persian"
    if Instr(1, ulo, "presstv.ir") > 0 or Instr(1, ulo, "presstv.com") > 0 then return "Persian"
    if Instr(1, ulo, "persiana.live") > 0 then return "Persian"
    if Instr(1, ulo, "alalam.ir") > 0 then return "Persian"
    if Instr(1, ulo, "irib.ir") > 0 or Instr(1, ulo, ".irib.") > 0 then return "Persian"

    if isPersian(title) then return "Persian"

    if Instr(1, glo, "iran") > 0 or Instr(1, glo, "irib") > 0 or Instr(1, glo, "persian") > 0 or Instr(1, glo, "farsi") > 0 then return "Persian"

    return ""
end function

function getFullGroup(title as String, groupRaw as String, url as String) as String
    lang = detectLanguage(title, groupRaw, url)

    if lang = "Persian"
        subCat = getSubCategory(groupRaw)
        if subCat = "General" then subCat = getSubCategoryFromTitle(title)
        return "Persian > " + subCat
    end if

    if lang = "Turkish"
        subCat = getSubCategory(groupRaw)
        if subCat = "General" then subCat = getSubCategoryFromTitle(title)
        return "Turkish > " + subCat
    end if

    return "General"
end function

function isPersian(title as String) as Boolean
    if title = invalid or title = "" then return false
    lo = LCase(title)

    if Instr(1, lo, "iran") > 0 then return true
    if Instr(1, lo, "persian") > 0 then return true
    if Instr(1, lo, "farsi") > 0 then return true
    if Instr(1, lo, "irib") > 0 then return true
    if Instr(1, lo, "irinn") > 0 then return true
    if Instr(1, lo, "channel 1") > 0 and Instr(1, lo, "ir") > 0 then return true
    if Instr(1, lo, "channel 2") > 0 and Instr(1, lo, "ir") > 0 then return true
    if Instr(1, lo, "channel 3") > 0 and Instr(1, lo, "ir") > 0 then return true
    if Instr(1, lo, "channel 4") > 0 and Instr(1, lo, "ir") > 0 then return true
    if Instr(1, lo, "channel 5") > 0 and Instr(1, lo, "ir") > 0 then return true
    if Instr(1, lo, "shoma") > 0 then return true
    if Instr(1, lo, "salamat") > 0 then return true
    if Instr(1, lo, "mostanad") > 0 then return true
    if Instr(1, lo, "namayesh") > 0 then return true
    if Instr(1, lo, "pooya") > 0 then return true
    if Instr(1, lo, "tamasha") > 0 then return true
    if Instr(1, lo, "jaam jam") > 0 then return true
    if Instr(1, lo, "jaamjam") > 0 then return true
    if Instr(1, lo, "jam-e jam") > 0 then return true
    if Instr(1, lo, "al-alam") > 0 or Instr(1, lo, "alalam") > 0 or Instr(1, lo, "al alam") > 0 then return true
    if Instr(1, lo, "hispan") > 0 then return true
    if Instr(1, lo, "sahar") > 0 then return true
    if Instr(1, lo, "omid") > 0 then return true
    if Instr(1, lo, "oxir") > 0 then return true
    if Instr(1, lo, "persiana") > 0 then return true
    if Instr(1, lo, "manoto") > 0 then return true
    if Instr(1, lo, "gem tv") > 0 or Instr(1, lo, "gemtv") > 0 then return true
    if Instr(1, lo, "varzesh") > 0 then return true
    if Instr(1, lo, "shaparak") > 0 then return true
    if Instr(1, lo, "ifilm") > 0 then return true
    if Instr(1, lo, "press tv") > 0 or Instr(1, lo, "presstv") > 0 then return true
    if Instr(1, lo, "ofogh") > 0 then return true
    if Instr(1, lo, "nasim") > 0 then return true
    if Instr(1, lo, "amouzesh") > 0 then return true
    if Instr(1, lo, "quran") > 0 then return true
    if Instr(1, lo, "hamadan") > 0 or Instr(1, lo, "hamedan") > 0 then return true
    if Instr(1, lo, "isfahan") > 0 or Instr(1, lo, "esfahan") > 0 or Instr(1, lo, "sepahan") > 0 then return true
    if Instr(1, lo, "khorasan") > 0 then return true
    if Instr(1, lo, "tabriz") > 0 then return true
    if Instr(1, lo, "sahand") > 0 then return true
    if Instr(1, lo, "azarbayjan") > 0 or Instr(1, lo, "azerbaijan") > 0 then return true
    if Instr(1, lo, "kermanshah") > 0 then return true
    if Instr(1, lo, "shiraz") > 0 then return true
    if Instr(1, lo, "fars") > 0 then return true
    if Instr(1, lo, "ahvaz") > 0 then return true
    if Instr(1, lo, "khuzestan") > 0 or Instr(1, lo, "khouzestan") > 0 then return true
    if Instr(1, lo, "mashhad") > 0 then return true
    if Instr(1, lo, "tehran") > 0 then return true
    if Instr(1, lo, "sari") > 0 then return true
    if Instr(1, lo, "rasht") > 0 then return true
    if Instr(1, lo, "golestan") > 0 or Instr(1, lo, "gorgan") > 0 then return true
    if Instr(1, lo, "semnan") > 0 then return true
    if Instr(1, lo, "yazd") > 0 then return true
    if Instr(1, lo, "zanjan") > 0 then return true
    if Instr(1, lo, "ardabil") > 0 then return true
    if Instr(1, lo, "bushehr") > 0 or Instr(1, lo, "boushehr") > 0 then return true
    if Instr(1, lo, "hormozgan") > 0 then return true
    if Instr(1, lo, "ilam") > 0 then return true
    if Instr(1, lo, "lorestan") > 0 then return true
    if Instr(1, lo, "markazi") > 0 then return true
    if Instr(1, lo, "mazandaran") > 0 then return true
    if Instr(1, lo, "qazvin") > 0 then return true
    if Instr(1, lo, "qom") > 0 then return true
    if Instr(1, lo, "sistan") > 0 then return true
    if Instr(1, lo, "baluchestan") > 0 then return true
    if Instr(1, lo, "gilan") > 0 then return true
    if Instr(1, lo, "kurdistan") > 0 or Instr(1, lo, "kordestan") > 0 then return true
    if lo = "kerman" or Instr(1, lo, "kerman ") > 0 or Instr(1, lo, " kerman") > 0 then return true
    if Instr(1, lo, "mahabad") > 0 or Instr(1, lo, "mhababad") > 0 then return true
    if Instr(1, lo, "sanandaj") > 0 then return true
    if Instr(1, lo, "urmia") > 0 or Instr(1, lo, "orumiyeh") > 0 then return true
    if Instr(1, lo, "bandarabbas") > 0 or Instr(1, lo, "bandar abbas") > 0 then return true
    if Instr(1, lo, "zahedan") > 0 then return true
    if Instr(1, lo, "bojnord") > 0 then return true
    if Instr(1, lo, "shahroud") > 0 then return true
    if Instr(1, lo, "birjand") > 0 then return true
    if Instr(1, lo, "arak") > 0 then return true
    if Instr(1, lo, "dezful") > 0 then return true
    if Instr(1, lo, "abadan") > 0 then return true
    if Instr(1, lo, "chaharmahal") > 0 or Instr(1, lo, "bakhtiari") > 0 then return true
    if Instr(1, lo, "kohgiluyeh") > 0 or Instr(1, lo, "boyer") > 0 then return true
    if Instr(1, lo, "alborz") > 0 or Instr(1, lo, "karaj") > 0 then return true
    return false
end function

function fetchUrl(url as String) as String
    if url = invalid or url = "" then return ""
    
    transfer = CreateObject("roUrlTransfer")
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()
    transfer.EnableFreshConnection(true)
    transfer.SetConnectTimeout(10)
    transfer.SetReadTimeout(10)
    transfer.AddHeader("User-Agent", "Roku/DVP-12.0")
    transfer.SetUrl(url)

    port = CreateObject("roMessagePort")
    transfer.SetMessagePort(port)

    if not transfer.AsyncGetToString()
        print "[M3UParser] AsyncGetToString failed for: " + url
        return ""
    end if

    msg = wait(15000, port)
    if msg = invalid
        print "[M3UParser] Timeout for: " + url
        transfer.AsyncCancel()
        return ""
    end if

    if type(msg) = "roUrlEvent"
        code = msg.GetResponseCode()
        if code = 200
            body = msg.GetString()
            if body <> invalid and body <> "" then return body
        else
            print "[M3UParser] HTTP " + intToStr(code) + " for: " + url
        end if
    end if
    return ""
end function

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

sub runTask()
    m.top.state = "RUN"

    m3uUrls = [
        "https://raw.githubusercontent.com/sasan-jafarzadeh/iptv-cleaner/main/live_list.m3u",
        "https://onureroz.com/indirmeler/turk/index.m3u"
    ]

    reg = CreateObject("roRegistrySection", "IPTVSources")
    keys = reg.GetKeyList()
    if keys <> invalid
        for each k in keys
            savedUrl = reg.Read(k)
            if savedUrl <> invalid and savedUrl <> ""
                m3uUrls.Push(savedUrl)
            end if
        end for
    end if

    allLines = []

    for each m_url in m3uUrls
        body = fetchUrl(m_url)
        if body <> "" and body <> invalid
            body = body.Replace(chr(13), "")
            chunks = body.Split(chr(10))
            if chunks <> invalid
                for each ln in chunks
                    if ln <> invalid then allLines.Push(ln)
                end for
            end if
        end if
    end for

    if allLines.Count() = 0
        m.top.content = CreateObject("RoSGNode", "ContentNode")
        m.top.state = "DONE"
        return
    end if

    groupOrder = []
    groupBuckets = {}

    currentTitle = ""
    currentGroup = "Other"
    currentLogo = ""

    for each line in allLines
        line = myTrim(line)
        if line = "" then continue for

        if Left(line, 7) = "#EXTINF"

            titlePos = Instr(1, line, ",")
            if titlePos > 0
                currentTitle = myTrim(Mid(line, titlePos + 1))
            end if

            groupStart = Instr(1, line, "group-title=\"")
            if groupStart > 0
                groupStart = groupStart + 13
                groupEnd = Instr(groupStart, line, "\"")
                if groupEnd > groupStart
                    currentGroup = myTrim(Mid(line, groupStart, groupEnd - groupStart))
                else
                    currentGroup = "Other"
                end if
            else
                currentGroup = "Other"
            end if

            logoStart = Instr(1, line, "tvg-logo=\"")
            if logoStart > 0
                logoStart = logoStart + 10
                logoEnd = Instr(logoStart, line, "\"")
                if logoEnd > logoStart
                    currentLogo = Mid(line, logoStart, logoEnd - logoStart)
                else
                    currentLogo = ""
                end if
            else
                currentLogo = ""
            end if

        else if Left(line, 7) = "http://" or Left(line, 8) = "https://"

            if currentTitle = "" then currentTitle = line

            channel = {
                title: currentTitle
                url: line
                logo: currentLogo
                group: currentGroup
            }

            finalGroup = getFullGroup(currentTitle, currentGroup, line)

            if not groupBuckets.DoesExist(finalGroup)
                groupBuckets[finalGroup] = []
                groupOrder.Push(finalGroup)
            end if

            groupBuckets[finalGroup].Push(channel)

            currentTitle = ""
            currentLogo = ""

        end if
    end for

    orderedGroups = []
    subCats = ["News", "Sports", "Music", "Entertainment", "General"]
    for each sc in subCats
        key = "Persian > " + sc
        if groupBuckets.DoesExist(key) then orderedGroups.Push(key)
    end for
    for each sc in subCats
        key = "Turkish > " + sc
        if groupBuckets.DoesExist(key) then orderedGroups.Push(key)
    end for
    if groupBuckets.DoesExist("General") then orderedGroups.Push("General")

    for each g in groupOrder
        found = false
        for i = 0 to orderedGroups.Count() - 1
            if orderedGroups[i] = g then found = true
        end for
        if not found then orderedGroups.Push(g)
    end for

    root = CreateObject("RoSGNode", "ContentNode")

    for each groupName in orderedGroups
        if groupBuckets.DoesExist(groupName)
            gNode = root.createChild("ContentNode")
            gNode.title = groupName

            for each ch in groupBuckets[groupName]
                item = gNode.createChild("ContentNode")
                item.title = ch.title
                item.url = ch.url
                if ch.logo <> ""
                    item.hdPosterUrl = ch.logo
                end if
            end for
        end if
    end for

    m.top.content = root
    m.top.state = "DONE"
end sub
