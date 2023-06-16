; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
; 这里和C语言的宏定义是一样的 
#define MyAppName "ActiveBg"
#define MyAppVersion "3.0.1"
#define MyAppPublisher "子礼_sq"
#define MyAppURL "https://gitee.com/s99q/ActiveBg"
#define MyAppExeFile "active_bg_run/active_bg.exe"
 
[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{796F2ABF-A452-4F6D-88C1-00D722007F85}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
; 设置安装在D盘，防止配置文件在C盘出问题
DefaultDirName=D:\{#MyAppName}
; DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
; Uncomment the following line to run in non administrative install mode (install for current user only.)
; PrivilegesRequired=lowest
; 输出目录
OutputDir=C:\Users\sq\Desktop
OutputBaseFilename=ActiveBgSetup
SetupIconFile=F:\language\flutter\ActiveBg\lib\assets\favicon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; 这里表示的是语言选项
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
; 这里表示的是添加的文件 * 表示下面所有
[Files]
;再添加文件的时候，选中哪个文件夹就表示将会把这个文件夹下面的整合到我们的目的文件架下面
Source: "D:\activeBg\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
 
[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkablealone
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkablealone
; 添加快捷方式
[icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeFile}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeFile}"; Tasks: desktopicon
;仅仅使用这种方式创建的快捷方式，没有很多权限，在CSDN上面看见的，是个坑
;Name: "{userdesktop}\{#MyAppName}";Filename: "{app}\{#MyAppExeFile}"; WorkingDir: "{app}"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeFile}\"; Tasks: quicklaunchicon