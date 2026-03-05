sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    
    ' ایجاد صحنه اصلی
    scene = screen.CreateScene("VideoScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub