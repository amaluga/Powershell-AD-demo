# Powershell-AD-demo
Demo overview: 
Creating random Users in CSV (including random passwords) > creating AD structure: ADUsers from CSV, OUs, Groups, roaming profiles, managing rights.

GUI actions:
Installations performed on Oracle VirtualBox 6.1.2 r135662:
1. Installed WS2016 - DC: 10.0.0.1, SERVER.DEMO.COM
2. Installed W10 - CLIENT: 10.0.0.2, CLIENT1.DEMO.COM
3. Added CLIENT1 to DEMO domain.

Rest of the actions were performed in Powershell on CLIENT1, including:
1. Creating random data required for ADUsers creation (Name, Surname, SAM etc.)
2. Creating OUs - 1st Line, 2nd Line, TM, IM, Admins, CEOs
3. Creating Groups
4. Creating default random passwords (requirements: 1 upperCase, 3 digits, 1 special, 8-10 length)
5. Exporting to CSV
6. ADUsers creation from CSV (added mechanism to avoid duplicated Names/SAMs)
7. Updating AD: creating groups, managing rights, creating Roaming Profiles for all users
... and more.

Running script notes:
- Powershell has to be run with Domain Admin credentials
- If after compiling the Main.ps1 there's a security compliance and/or module import error - please run each of the first 3 lines seperately
- Main.ps1: (line 4) set location for your path of demo folder
- For access to AD cmdlets please download RSAT module

UPDATE 9/6/2020:
- DemoModule.psm1: There was a bug on 133 line - TMs path has been granted not only for TMs but also for IMs, Admins, CEOs. Now it adds respectively.
- DemoModule.psm1: For clarification purpose, added commentary on 197 about new sort strings method requirement
- DemoModule.psm1 and Main.ps1: On line 302 in Add-DemoADGroupMembers - changed indistinct argument name "project" to "tier". Now it looks much clearer. Respectively changed in Main.ps1 on line 28 and 29
- Main.ps1: Changed absolute to relative paths on 5, 7, 13 lines
- Set server name to SERVER.DEMO.COM - easier to perform tests
- Set execution policy to unrestricted as when downloading it from GitHub, importing the module is being blocked cause of unsigned Internet file - to be improved
