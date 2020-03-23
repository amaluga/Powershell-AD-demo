Demo overview: 
Creating random Users in CSV (including random passwords) > creating AD structure: ADUsers from CSV, OUs, Groups, roaming profiles, managing rights.

GUI actions:
Installations performed on Oracle VirtualBox 6.1.2 r135662:
1. Installed WS2016 - DC: 10.0.0.1, WIN-E83VKKDADK7 
2. Installed W10 - CLIENT: 10.0.0.2, CLIENT1
3. Added CLIENT1 to DEMO domain.

Rest of the actions were performed in Powershell, including:
A: Creating random data required for ADUsers creation (Name, Surname, SAM etc.)
B: Creating OUs - 1st Line, 2nd Line, TM, IM, Admins
C: Creating Groups
C: Creating default random passwords (requirements: 1 upperCase, 3 digits, 1 special, 8-10 length)
D: Exporting to CSV
E: ADUsers creation from CSV (added mechanism to avoid duplicated Names/SAMs)
F: Updating AD: creating groups, managing rights, creating Roaming Profiles for all users
... and more.


