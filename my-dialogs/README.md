# Dialogs & Work Items

This bot can be triggered from Control Room while running with [WFA](https://robocorp.com/docs/control-room/configuring-workforce/overview#what-is-robocorp-workforce-agent)
on a local machine (my Mac as the example shown below). Since it has a display, it can
render Dialogs as well, while still being capable of interacting with [Work Items](https://robocorp.com/docs/development-guide/control-room/work-items#what-is-a-work-item).

<img width="1424" alt="Screenshot 2022-09-12 at 09 46 18" src="https://user-images.githubusercontent.com/709053/189590643-122efcd6-6980-4449-a9ff-cc564e9e53b2.png">


## ⚠️ Danger

Testing purposes only, don't use anything like this in production, because of:
- Anybody with access into the Control Room organization & Process will be able to
  trigger it and thus "take control" of your machine. (or the env running WFA)
- WFA is designed to be **unattended** and should stay like that.


### Solution(s)

1. An Assistant which collects info from the user then triggers a new unattended
   Process with Work Item data from the attended one.
2. An Assistant reading Process' Work Items data (queue) and does work based on that.

Read more on [Process API](https://robocorp.com/docs/control-room/apis-and-webhooks/process-api)
- https://robocorp.com/docs/control-room/apis-and-webhooks
- https://robocorp.com/docs/libraries/rpa-framework/rpa-robocorp-process
