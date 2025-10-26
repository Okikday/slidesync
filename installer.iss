[Setup]
AppName=SlideSync
AppVersion=1.0.0
DefaultDirName={autopf}\slidesync
DefaultGroupName=SlideSync
OutputBaseFilename=slidesync_setup
OutputDir=installer_output
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\SlideSync"; Filename: "{app}\slidesync.exe"
Name: "{autodesktop}\SlideSync"; Filename: "{app}\slidesync.exe"

[Run]
Filename: "{app}\slidesync.exe"; Description: "Launch SlideSync"; Flags: nowait postinstall skipifsilent