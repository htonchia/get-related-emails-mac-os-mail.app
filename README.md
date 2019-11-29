# get-related-emails-mac-os-mail.app

Mac OS applescript for mail.app

Features:
- window progress bar
- menu item from the service menu of mail.app
- move related sent emails to the current mailbox

Issue to solve:
Being able to fectch the sent emails related to a conversation and move them in the current mailbox.

For example, if you want to trash a conversation, you trash the conversation in the current mailbox, 
but that won't trash your sent emails from the sent box.
By using this script, after you have trashed your conversation, you go to trash, select an email and fetch all the related
emails from the OUTBOX and move them in the Trash. Et Voilà.
But you can also do it from an other mailbox, doesn't have to be Trash.

Launching from the service menu (if you have followed the instruction on how to do it):
Please note the shortcut ^R.
You may note that my Mac speaks French. Sorry for that.
![alert if no email selected](https://raw.githubusercontent.com/htonchia/get-related-emails-mac-os-mail.app/master/images/MenuService.png)

First you need to select the email for which you want to look for related emails. If you don't do it, you will get an alert:
![alert if no email selected](https://raw.githubusercontent.com/htonchia/get-related-emails-mac-os-mail.app/master/images/Capture%20d’écran%20un.png)

Then it will ask you if you want to move the email found to the current mailbox, here TRASH:
![message to move found emails](https://raw.githubusercontent.com/htonchia/get-related-emails-mac-os-mail.app/master/images/Capture%20d’écran%20deux.png)


The mailbox after the move:

![the mailbox after the move](https://raw.githubusercontent.com/htonchia/get-related-emails-mac-os-mail.app/master/images/Capture%20d’écran%20trois.png)
