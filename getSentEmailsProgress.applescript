(*
For all selected messages, this script will look for related messages in the sent box.

The related messages are defined by same object (if Re: or Fwd: in front, it is removed)
and recipient contains the sender of the message.
As sometimes some info are added to the object, it check whether one contains the other.
So it misses less messages (than mail.app) but as very few false positive.
Then it offers to move the related messages in the same mailbox as the message.
After you can move manually all the message in the thread together to an archive for example.

There are several ways to use that script.
My choices are:
- having it in the mail service menu with a shortcut
- displaying a progress bar, as it can be long if there are many mails in the sent box

A PROGRESS BAR
To display an independant progress bar, it has to be launch as an app.
it means that you have to export it to application format from the Apple script editor.
it will be called:
getSentEmailsProgress.app

B SERVICE MENU
To get it in the mail service menu, you need to define a worklow with the automator.
It will be saved as:
/Users/myname/Library/Services/the chosen name for the menu.workflow 

B-1 DEFINING A WORKFLOW
There are two ways to do it:
- a one file one that won't manage the progress bar
- a two files one that will launch the independant app getSentEmailsProgress.app via a shell script.
In both case you need to create a new automator document.
When prompted, choose a document type of Service and click Choose.
At the top of the Automator document, configure the service.
no input
mail.app
Then choose the right action in the action library panel it depends on the above choice.

B-1-1 ONE FILE WORKFLOW without progress var
Chose the action Run AppleSScript in the library panel.
Drag Run AppleScript to the workflow area.
Copy the script code 
Save the Automator document.
When prompted, enter a name for the service.
The name will appear in the Services menu.

B-1-2 WORFLOW FOR PROGRESS BAR
you have somewhere/path the getSentEmailsProgress.app
Chose the action Run Shell Script in the library panel.
Drag Run Shell Script to the workflow area.
Write the code to launch the /somewhere/path/getSentEmailsProgress.app:
open /somewhere/path/getSentEmailsProgress.app
Save the Automator document.
When prompted, enter a name for the service.
The name will appear in the Services menu.

B-2 SHORTCUT
Finally you can add a shortcut via system preferences -> keyboard -> shortcut
use the same name.

C LAUNCHING outside the service menu
Several ways:
Progress on the bottom of the editor:
- launch from the script editor, progress is shown on the bottom of the editor
Independant progress bar:
- launch the app (defined in A) by double click on getSentEmailsProgress.app
- launch from the dock (once dragged there)

D ALIASES
It cannot follow through aliases.
If the sender of the email as a different address to the one to which it was sent to, due to alias, those will not be considered as being from the same conversation.

*)

property my_account : "myaddresse@egg.org"
property processButton : "Deplacer vers "
property continueButton : "Ne pas deplacer"
property cancelButton : "Cancel"
property found : "Trouve : "
property toProcess : "A traiter : "
property my_inbox : "INBOX"
property my_outbox : "OUTBOX"
property alertSelect : "Selectionner au moins un message"

on trim_subject(the_subject)
	set pres to {"Re: ", "Fwd: "}
	set res to the_subject
	repeat with pre in pres
		if res contains pre then
			set AppleScript's text item delimiters to pre
			set theTextItems to every text item of res
			set AppleScript's text item delimiters to ""
			set sc to (the count of theTextItems)
			set res to item sc of theTextItems
		end if
	end repeat
	return res
	
end trim_subject

on run
	
	-- put Mail in front if applet launched from terminal
	tell application "Mail" to activate
	
	-- GET the emails to process, for which we will look for the related sent emails
	tell application "Mail"
		set these_messages to the selected messages of the front message viewer
		try
			set the message_count to the count of these_messages
			
			-- get the_inbox from first message as mbox to move to
			-- get account from the_inbox as account to use to get OUTBOX from
			-- on account error use my_account
			-- on mailbox error use my_inbox from my_account
			if message_count > 0 then
				set this_message to item 1 of these_messages
				try
					set the_inbox to (mailbox of this_message)
					try
						set the_account to (account of the_inbox)
						--set nacc to (name of the_account)
						--display dialog nacc
					on error
						set the_account to (account my_account)
					end try
				on error
					--display dialog "error mbox"
					set the_account to (account my_account)
					set the_inbox to mailbox my_inbox of the_account
				end try
			end if
		on error
			tell me to activate
			set message_count to 0
			display alert alertSelect
			tell me to quit
		end try
		set the_outbox to mailbox my_outbox of the_account
		set out_messages to messages in the_outbox
		set sent_message_count to (the count of messages in the_outbox)
		set total_steps to sent_message_count + message_count
		set bcolors to {}
		set exitLoop to false
		
		display dialog toProcess & (total_steps) & " emails (sent and selected)" giving up after 2
		
		--GET all the subject and sender of the inbox emails to process 
		-- set a new list without the message with no subject
		set the_subjects to {}
		--set the_senders to {}
		--set the_inboxes to {}
		set to_process to {}
		
	end tell
	set progress total steps to total_steps
	set progress completed steps to 0
	set progress description to "Processing Messages..."
	set progress additional description to "inbox message"
	tell me to activate
	
	-- GET all the subjects the inbox emails to process 
	repeat with message_i from 1 to message_count
		set progress completed steps to message_i
		tell application "Mail"
			set this_message to item message_i of these_messages
			--set this_sender to the sender of this_message
			--set this_sender_address to (extract address from this_sender)
			--copy this_sender_address to the end of the_senders
			try
				set this_subject to (subject of this_message) as Unicode text
				--set this_mailbox to (mailbox of this_message)
				if this_subject is "" then error
				set prev to this_subject
				set this_subject to trim_subject(this_subject) of me
				copy this_subject to the end of the_subjects
				copy this_message to the end of to_process
				if prev is not this_subject then
					display dialog prev & "-> using: " & this_subject giving up after 2
				end if
			on error
				display dialog "error " & this_subject
				set this_subject to "NO SUBJECT"
			end try
		end tell
	end repeat
	set message_count_2 to (count of to_process)
	tell me to activate
	set progress completed steps to message_count
	set progress additional description to "sent message"
	-- PROCESS all the sent emails and check their subjects and tos versus these_messages
	set exit_loop to false
	repeat with message_sent_i from 1 to sent_message_count
		tell me to activate
		set progress completed steps to message_count + message_sent_i - 1
		if exit_loop then
			exit repeat
		end if
		repeat 1 times -- fake loop to break so as to continue to next
			tell application "Mail"
				set out_message to item (sent_message_count - message_sent_i + 1) of out_messages
				try
					set out_subject to (subject of out_message) as Unicode text
					set out_subject to trim_subject(out_subject) of me
					if out_subject is "" then error
				on error
					-- break the fake loop to continue to next message
					exit repeat
				end try
				-- COMPARE out_subject to the_subjects
				repeat with i_message from 1 to message_count_2
					set in_subject to item i_message of the_subjects
					if in_subject contains out_subject or out_subject contains in_subject then
						--GET sender
						set this_message to item i_message of to_process
						set this_sender to the sender of this_message
						set this_sender_address to (extract address from this_sender)
						-- GET tos
						set to_adresses to {}
						try
							set myrecipients to (get recipient in out_message)
							repeat with i_rec from 1 to count of myrecipients
								set addr to (address of item i_rec) of myrecipients as string
								copy addr to the end of to_adresses
							end repeat
						end try
						-- CHECK if sender is in tos
						if to_adresses contains this_sender_address then
							-- found a related email
							-- GET mailbox of this_message for move
							set this_mailbox to (mailbox of this_message)
							set mbox_name to name of this_mailbox
							set date_sent to date sent of out_message
							-- ASK if we move it to inbox
							set theDialogText to "message inbox : " & in_subject & "

" & found & out_subject & "  to: " & this_sender_address & " " & date_sent
							display dialog theDialogText buttons {cancelButton, continueButton, processButton & mbox_name} default button processButton & mbox_name
							if button returned of result = processButton & mbox_name then
								move out_message to this_mailbox
								display dialog "moving" giving up after 1
							else
								if button returned of result = cancelButton then
									-- we should exit all loops...
									set exit_loop to true
								end if
							end if
							-- we have found so we stop looking
							exit repeat
						end if
					end if
				end repeat
			end tell
		end repeat
	end repeat
end run